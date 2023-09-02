#!/usr/bin/env bash

set -e
HASH_DIR="/etc/unCookie/containers/hashes"
IMAGE_TMPFILE=$(mktemp --suffix="-image.tgz")

# https://github.com/containers/podman/issues/17609
IMAGE_DIGEST=$(skopeo inspect docker://${IMAGE_UPSTREAM_HOST}/${IMAGE_UPSTREAM_NAME}:${IMAGE_UPSTREAM_TAG} | jq -r '.Digest')
if [ "${IMAGE_DIGEST}" = "$(cat ${HASH_DIR}/${IMAGE_FINAL_NAME}/digest)" ]; then
	echo "Already having newest contaimer image digest!"
	exit 0
fi

# https://nixos.wiki/wiki/Docker#How_to_calculate_the_sha256_of_a_pulled_image
skopeo copy docker://${IMAGE_UPSTREAM_HOST}/${IMAGE_UPSTREAM_NAME}@${IMAGE_DIGEST} \
	docker-archive://${IMAGE_TMPFILE}:localhost/${IMAGE_FINAL_NAME}:${IMAGE_FINAL_TAG}

# first download then update everything
mkdir -p ${HASH_DIR}/${IMAGE_FINAL_NAME}
echo ${IMAGE_DIGEST} > ${HASH_DIR}/${IMAGE_FINAL_NAME}/digest

# nix hash file ${IMAGE_TMPFILE}
IMAGE_NIXFILEHASH=$(sha256sum ${IMAGE_TMPFILE} | cut -f1 -d' ' | xxd -r -p | base64)
echo "sha256-"${IMAGE_NIXFILEHASH} > ${HASH_DIR}/${IMAGE_FINAL_NAME}/nix-store

rm ${IMAGE_TMPFILE}
exit 0
