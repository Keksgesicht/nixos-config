#!/bin/bash

### -------------------------- ###
### valid cloudflare proxy IPs ###
### -------------------------- ###

cloudflare_files="/mnt/cache/appdata/swag/nginx/cloudflare-proxy"

# reset files
truncate -s 0 ${cloudflare_files}-ipv4.txt.tmp
truncate -s 0 ${cloudflare_files}-ipv6.txt.tmp

# download lists
wget https://www.cloudflare.com/ips-v4 -O ${cloudflare_files}-ipv4.txt.tmp
wget https://www.cloudflare.com/ips-v6 -O ${cloudflare_files}-ipv6.txt.tmp

# nginx allow syntax
sed -i 's/^/allow /g'	${cloudflare_files}-ipv[46].txt.tmp
sed -i 's/$/;/g'		${cloudflare_files}-ipv[46].txt.tmp

# if successfull overwrite exiting config
if [ 1 -lt $(cat "${cloudflare_files}-ipv4.txt.tmp" | wc -l) ]; then
	mv ${cloudflare_files}-ipv4.txt.tmp ${cloudflare_files}-ipv4.txt
fi
if [ 1 -lt $(cat "${cloudflare_files}-ipv6.txt.tmp" | wc -l) ]; then
	mv ${cloudflare_files}-ipv6.txt.tmp ${cloudflare_files}-ipv6.txt
fi
