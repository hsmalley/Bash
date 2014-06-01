#!/bin/bash
set -o nounset
set -o errexit

sudo sysctl kernel.yama.ptrace_scope=0
playonlinux
sudo sysctl kernel.yama.ptrace_scope=1
