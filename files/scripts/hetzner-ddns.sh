#!/usr/bin/env bash

# own modified version of https://github.com/filiparag/hetzner_ddns

self='hetzner-ddns.service'
api_ip='https://ip.hetzner.com/'
api_rec='https://dns.hetzner.com/api/v1/records'
api_zone='https://dns.hetzner.com/api/v1/zones'

test_configuration() {
    records_escaped="$(echo "$records" | sed 's:\*:\\\*:g')"

    if [ -z "$TTL" ] || [ "$TTL" -lt 30 ]; then
        logger -t $self -p 5 \
            'Info: TTL is invalid, defaulting to 1000 seconds'
        TTL=1000
    fi
    if [ -z "$API_KEY" ]; then
        logger -t $self -p 3 'Error: API key is not set, unable to proceed'
        exit 78
    fi
    if [ -z "$domain" ]; then
        logger -t $self -p 3 'Error: Domain is not set, unable to proceed'
        exit 78
    fi
    if [ -z "$records" ]; then
        logger -t $self -p 4 'Warning: Records are not set, exiting cleanly'
        exit 11
    fi
}

test_api_key() {
    if curl $api_zone -H "Auth-API-Token: $API_KEY" 2>/dev/null | \
    grep -q 'Invalid authentication credentials'; then
        logger -t $self -p 3 'Error: Invalid API key'
        exit 22
    fi
}

get_zone() {
    zone="$(
        curl $api_zone -H "Auth-API-Token: $API_KEY" 2>/dev/null | \
        jq -r '.zones[] | .name + " " + .id' | \
        awk -v d="$domain" '$1==d {print $2}'
    )"
    if [ -z "$zone" ]; then
        logger -t $self -p 3 "Error: Unable to fetch zone ID for domain $domain"
        return 1
    else
        logger -t $self "Zone for ${domain}: $zone"
        return 0
    fi
}

get_record() {
    if [ -n "$zone" ]; then
        record_ipv4="$(
            echo "$records_json" | \
            jq -r '.records[] | .name + " " + .type + " " + .id' | \
            awk -v r="$1" -v d="$domain" \
                '($1==r || $1==sprintf("%s.%s",r,d)) && $2=="A" {print $3 }'
        )"
        record_ipv6="$(
            echo "$records_json" | \
            jq -r '.records[] | .name + " " + .type + " " + .id' | \
            awk -v r="$1" -v d="$domain" \
                '($1==r || $1==sprintf("%s.%s",r,d)) && $2=="AAAA" {print $3 }'
        )"
    fi
    if [ -z "$record_ipv4" ] && [ -z "$record_ipv6" ]; then
        return 1
    else
        logger -t $self "IPv4 record for ${1}.${domain}: ${record_ipv4:-(missing)}"
        logger -t $self "IPv6 record for ${1}.${domain}: ${record_ipv6:-(missing)}"
        return 0
    fi
}

get_records() {
    # Get all record IDs
    records_json="$(
        curl "${api_rec}?zone_id=$zone" -H "Auth-API-Token: $API_KEY" 2>/dev/null
    )"
    for current_record in $records_escaped; do
        current_record="$(echo "$current_record" | sed 's:\\::')"
        if get_record "$current_record"; then
            records_ipv4="$records_ipv4$current_record=$record_ipv4 "
            records_ipv6="$records_ipv6$current_record=$record_ipv6 "
        else
            logger -t $self -p 4 \
                "Warning: Missing both A and AAAA records for $current_record.$domain"
        fi
    done
    if [ -z "$records_ipv4" ] && [ -z "$records_ipv6" ]; then
        logger -t $self -p 3 "Error: No applicable records found $domain"
        return 1
    fi
}

get_record_ip_addr() {
    # Get record's IP address
    if [ -n "$record_ipv4" ]; then
        ipv4_rec="$(
            curl "$api_rec/$record_ipv4" \
                -H "Auth-API-Token: $API_KEY" 2>/dev/null | \
                jq -r '.record.value'
        )"
    fi
    if [ -n "$record_ipv6" ]; then
        ipv6_rec="$(
            curl "$api_rec/$record_ipv6" \
                -H "Auth-API-Token: $API_KEY" 2>/dev/null | \
                jq -r '.record.value'
        )"
    fi
    if [ -n "$record_ipv4" ]; then
        if [ -z "$ipv4_rec" ] || [ "$ipv4_rec" = 'null' ]; then
            logger -t $self -p 4 \
                "Warning: Unable to fetch previous IPv4 address for $current_record.$domain"
            ipv4_rec=''
        fi;
    fi
     if [ -n "$record_ipv6" ]; then
        if [ -z "$ipv6_rec" ] || [ "$ipv6_rec" = 'null' ]; then
            logger -t $self -p 4 \
                "Warning: Unable to fetch previous IPv6 address for $current_record.$domain"
            ipv6_rec=''
        fi;
    fi
    if [ -z "$ipv4_rec" ] && [ -z "$ipv6_rec" ]; then
        return 1
    fi
}

get_my_ip_addr() {
    # Get current public IP address
    ipv4_cur="$(
        curl -4 $api_ip 2>/dev/null
    )"

    # wierd privacy fix
    ipv6_cur="$(
        ip addr show "${MY_IFLINK}" 2>/dev/null | \
        awk '$1 == "inet6" && $2 !~ /^fe80:/ && $2 !~ /^fd00:/ &&
            /'"${MY_IPV6_SUFFIX}"'/ {gsub(/\/.*$/, "", $2); print $2}' | \
        head -1
    )"
    if [ -z "$ipv6_cur" ]; then
        ipv6_cur="$(
            curl -6 $api_ip 2>/dev/null | sed 's/:$/:1/g'
        )"
    fi

    if [ -z "$ipv4_cur" ] && [ -z "$ipv6_cur" ]; then
        logger -t $self -p 3 'Error: Unable to fetch current self IP address'
        return 1
    fi
}

set_record() {
    # Update record if IP address has changed
    if [ -n "$record_ipv4" ] && [ -n "$ipv4_cur" ] \
    && [ "$ipv4_cur" != "$ipv4_rec" ]; then
        curl -X "PUT" "$api_rec/$record_ipv4" \
            -H 'Content-Type: application/json' \
            -H "Auth-API-Token: $API_KEY" \
            -d "{
            \"value\": \"$ipv4_cur\",
            \"ttl\": $TTL,
            \"type\": \"A\",
            \"name\": \"$current_record\",
            \"zone_id\": \"$zone\"
            }" 1>/dev/null 2>/dev/null &&
        logger -t $self \
            "Update IPv4 for $current_record.$domain: $ipv4_rec => $ipv4_cur"
    fi
    if [ -n "$record_ipv6" ] && [ -n "$ipv6_cur" ] \
    && [ "$ipv6_cur" != "$ipv6_rec" ]; then
        curl -X "PUT" "$api_rec/$record_ipv6" \
            -H 'Content-Type: application/json' \
            -H "Auth-API-Token: $API_KEY" \
            -d "{
            \"value\": \"$ipv6_cur\",
            \"ttl\": $TTL,
            \"type\": \"AAAA\",
            \"name\": \"$current_record\",
            \"zone_id\": \"$zone\"
            }" 1>/dev/null 2>/dev/null &&
        logger -t $self \
            "Update IPv6 for $current_record.$domain: $ipv6_rec => $ipv6_cur"
    fi
}

pick_record() {
    # Get record ID from array
    echo "$2" | \
    awk "{
        for(i=1;i<=NF;i++){
            n=\$i;gsub(/=.*/,\"\",n);
            r=\$i;gsub(/.*=/,\"\",r);
            if(n==\"$1\"){
                print r;break
            }
        }}"
}

set_records() {
    # Get my public IP address
    if get_my_ip_addr; then
        # Update all records if possible
        for current_record in $records_escaped; do
            current_record="$(echo "$current_record" | sed 's:\\::')"
            record_ipv4="$(pick_record "$current_record" "$records_ipv4")"
            record_ipv6="$(pick_record "$current_record" "$records_ipv6")"
            if [ -n "$record_ipv4" ] || [ -n "$record_ipv6" ]; then
                get_record_ip_addr && set_record
            fi
        done
    fi
}

run_ddns() {
    test_configuration
    test_api_key

    while ! get_zone || ! get_records; do
        sleep $((TTL/2))
        logger -t $self 'Retrying to fetch zone and record data'
    done

    set_records
}

run_ddns
