#!/usr/bin/env bash

set -e
set -o pipefail

JSON_DIR="/etc/unCookie/containers"
JSON_FILE="${JSON_DIR}/${IMAGE_FINAL_NAME//localhost\//}.json"
IMAGE_TMPFILE=$(mktemp --suffix=".json")

# https://github.com/containers/podman/issues/17609
IMAGE_DIGEST_NEW=$(skopeo inspect docker://${IMAGE_UPSTREAM_HOST}/${IMAGE_UPSTREAM_NAME}:${IMAGE_UPSTREAM_TAG} | jq -r '.Digest')

if [ -f ${JSON_FILE} ]; then
	IMAGE_DIGEST_OLD=$(cat ${JSON_FILE} | jq -r '.imageDigest')
	if [ "${IMAGE_DIGEST_NEW}" = "${IMAGE_DIGEST_OLD}" ]; then
		echo "Already having newest container image digest!"
		exit 0
	fi
fi

# first download then update everything
nix-prefetch-docker --json \
	--image-name ${IMAGE_UPSTREAM_HOST}/${IMAGE_UPSTREAM_NAME} \
	--image-digest ${IMAGE_DIGEST_NEW} \
	--final-image-name ${IMAGE_FINAL_NAME} \
	--final-image-tag ${IMAGE_FINAL_TAG} \
	> ${IMAGE_TMPFILE}

mkdir -p ${JSON_DIR}
mv ${IMAGE_TMPFILE} ${JSON_FILE}
chmod 644 ${JSON_FILE}
exit 0
