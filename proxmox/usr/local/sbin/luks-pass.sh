#!/usr/bin/env sh
set -e

sleep $(( 3 * CRYPTTAB_TRIED ))
cat /dev/disk/by-partuuid/${CRYPTTAB_KEY}
