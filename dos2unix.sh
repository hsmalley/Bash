#!/bin/bash
set -o nounset
set -o errexit

find ./ -type f -exec dos2unix {} \;
