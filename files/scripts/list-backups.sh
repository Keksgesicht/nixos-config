#!/usr/bin/env bash

bck_root_path="/mnt/main/backup_main/boot/root"

file=$1
if ! [ -e "${file}" ]; then
	echo "No such file or directory \"${file}\"" >&2
	exit 1
fi

real_path=$(realpath "${file}")
mount_replacer=$(awk '$4 ~ /bind/ {printf "s|%s|%s|\n", $2, $1}' /etc/fstab)
for rr in ${mount_replacer}; do
	 rpath=$(echo "${real_path}" | sed -e "${rr}")
done

sep_count=$(echo "${rpath}" | awk -F'/' '{print NF}')
path_d=$(echo "${rpath}" | cut -d '/' -f2)

if [ 4 -le "${sep_count}" ] && [ "${path_d}" == "mnt" ]; then
	path_r=$(echo "${rpath}" | cut -d '/' -f1-4)
	path_s=$(echo "${rpath}" | cut -d '/' -f5-)
else
	case ${path_d} in
	"etc")
		path_r="/mnt/main/etc"
		path_s=$(echo "${rpath}" | cut -d '/' -f3-)
	;;
	"home")
		path_r="/mnt/main/home"
		path_s=$(echo "${rpath}" | cut -d '/' -f3-)
	;;
	"var")
		path_r="/mnt/main/var"
		path_s=$(echo "${rpath}" | cut -d '/' -f3-)
	;;
	"dev" | "proc" | "run" | "sys" | "tmp" )
		echo "Unsupported directory /${path_d}" >&2
		exit 2
	;;
	*)
		path_r="/mnt/main/root"
		path_s=$(echo "${rpath}" | cut -d '/' -f2-)
	;;
	esac
fi

echo "${path_r}/.backup/"'*'"/${path_s}"
ls -d1 "${path_r}/.backup/"*"/${path_s}"

echo ""

echo "${bck_root_path}/"'*'"${real_path}"
ls -d1 "${bck_root_path}/"*"${real_path}"
