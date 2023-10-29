#!/bin/bash -ex

BIN_DIR=$(dirname $(realpath $0))
DATA_DIR="${TARGET_DIR}/mailcow/data"
mkdir -p ${DATA_DIR}/
cd ${TARGET_DIR}/

rsync -avHA \
	-e "ssh" \
	--delete --delete-excluded \
	--include-from="${BIN_DIR}/rsync.pattern" \
	hetzner-mailcow:/ \
	${DATA_DIR}/

TAR_FILE=$(realpath ${TARGET_DIR}/Upload2Cloud/mailcow.tar.gz)
cd ${DATA_DIR}/ && tar cf - . | gzip -9 >${TAR_FILE}
