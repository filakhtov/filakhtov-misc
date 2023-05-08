#!/usr/bin/env sh
set -e

if [ -z "$1" ]; then
  echo "Usage: ${0##*/} <disk-partuuid>"
  exit 1
fi

block_device_partuuid=$1
parent_block_device_name="$( lsblk -no pkname "/dev/disk/by-partuuid/${block_device_partuuid}" | head -1 )"

if [ -z "$parent_block_device_name" ]; then
  echo "Unable to find parent device ${block_device_partuuid}"
  exit 1
fi

echo 1 > "/sys/block/${parent_block_device_name}/device/delete"
