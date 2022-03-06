#!/bin/sh

torrent=$(transmission-remote -l | grep -v 'Sum' | grep -v "ID" | dmenu -l 10 -p "Pick a torrent:" | awk '{print $1;}')
[[ -z $torrent ]] && exit

option=$(echo -e "start\nstop\nremove\nremove and delete\nquit" | dmenu -l 10 -p "Pick an option:") || exit

[[ "$option" == "quit" ]] && exit
[[ "$option" == "start" ]] && transmission-remote -t "$torrent" -s && /usr/bin/pkill -RTMIN+7 dwmblocks
[[ "$option" == "stop" ]] && transmission-remote -t "$torrent" -S && /usr/bin/pkill -RTMIN+7 dwmblocks
[[ "$option" == "remove" ]] && transmission-remote -t "$torrent" -r && /usr/bin/pkill -RTMIN+7 dwmblocks
[[ "$option" == "remove and delete" ]] && transmission-remote -t "$torrent" -rad && /usr/bin/pkill -RTMIN+7 dwmblocks

