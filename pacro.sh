#!/bin/bash
set -o nounset
set -o errexit

pacman -Rns $(pacman -Qtdq)
