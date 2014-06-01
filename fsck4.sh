#!/bin/bash
set -o nounset
set -o errexit

if [ $# -ge 1 ]; then
        drive="$1"
        echo "Running Drive Check on ${drive}"
        fsck.ext4 -cDfty -C 0 ${drive} || exit 1
else
        echo "Enter a drive to check e.g. /dev/sdx1"
fi
