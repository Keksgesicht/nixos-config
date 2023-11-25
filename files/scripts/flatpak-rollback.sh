#!/usr/bin/env bash

if [ -z "$1" ]; then
	echo "No app or runtime specified"
	exit 1
fi
FLAT_NAME="$1"

FLAT_COMMIT=$(flatpak info ${FLAT_NAME} | awk -F': ' '/Parent:/ {print $2}')
if [ -z "${FLAT_COMMIT}" ]; then
	echo "Cannot resolve ealier version of ${FLAT_NAME}"
	exit 2
fi

${AUTH} flatpak update --commit=${FLAT_COMMIT} ${FLAT_NAME}
flatpak info ${FLAT_NAME}
