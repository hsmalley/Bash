#!/bin/bash
set -o nounset
set -o errexit

pacman -U linux-pf-core2-3.3.2-1-$CPUTYPE.pkg.tar.xz linux-pf-headers-core2-3.3.2-1-$CPUTYPE.pkg.tar.xz

mkinitcpio -p linux-pf
