#!/bin/bash

# renew SSL/TLS certificate
podman exec \
	swag \
	certbot renew
