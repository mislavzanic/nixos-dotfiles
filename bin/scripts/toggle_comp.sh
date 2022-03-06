#!/bin/bash

if pgrep compton &>/dev/null; then
    echo "Turning xcompmgr OFF"
    pkill compton &
else
    echo "Turning xcompmgr ON"
    setsid compton &
fi

exit 0
