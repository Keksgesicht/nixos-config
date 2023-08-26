#!/bin/sh

if ! diff /scripts/unbound.conf /etc/unbound/unbound.conf.sample >/dev/null; then
	cp /scripts/unbound.conf /etc/unbound/unbound.conf.sample
fi

if ! [ -f /etc/unbound/root.hints ] || [ /etc/unbound/root.hints -ot /scripts/root.hints ]; then
	cp /scripts/root.hints /etc/unbound/root.hints
fi

mkdir -p /etc/unbound/keys
chmod 775 /etc/unbound/keys
chown -R unbound:unbound /etc/unbound

unbound-anchor -4 -r /etc/unbound/root.hints -a /etc/unbound/keys/trusted.key
unbound-control-setup -d /etc/unbound/keys/

unbound-checkconf /etc/unbound/unbound.conf
if [ "$?" != "0" ] ; then
	echo "#=======================#"
	echo "| ERROR: CONFIG DAMAGED |"
	echo "#=======================#"
	exit 1
fi

exec unbound
