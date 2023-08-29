#!/bin/bash

# renew SSL/TLS certificate
podman exec \
	proxy \
	certbot renew
