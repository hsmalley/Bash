#!/bin/bash
set -o nounset
set -o errexit

sed -i 's/"displayName": "ninekeys"/"displayName": "hugh"/' ~/.minecraft/launcher_profiles.json

nmcli d disconnect iface enp6s0

exec /usr/bin/minecraft &

sleep 30

nmcli c up uuid cc06a5d9-1970-4156-8dcb-78bd2479c288
