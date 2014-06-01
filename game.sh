#!/bin/bash
set -o nounset
set -o errexit

if [ $# -ge 1 ]; then
        game="$(which $1)"
        openbox="$(which openbox)"
        tmpgame="/tmp/tmpgame.sh"
        DISPLAY=:7
        echo -e "${openbox} &\n${game}" > ${tmpgame}
        echo "starting ${game}"
        xinit ${tmpgame} -- :7 || exit 1
else
        echo "not a valid argument"
fi

