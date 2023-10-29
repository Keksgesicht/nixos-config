#!/bin/bash -ex

BIN_DIR=$(dirname $(realpath $0))
DATA_DIR="${TARGET_DIR}/pihole/data"
mkdir -p ${DATA_DIR}/
cd ${TARGET_DIR}/

rsync -avHA \
	-e "ssh" \
	--delete --delete-excluded \
	--include-from="${BIN_DIR}/rsync.pattern" \
	pihole-root:/ \
	${DATA_DIR}/

TAR_FILE=$(realpath ${TARGET_DIR}/Upload2Cloud/pihole.tar.gz)
cd ${DATA_DIR}/ && tar cf - . | gzip -9 >${TAR_FILE}
