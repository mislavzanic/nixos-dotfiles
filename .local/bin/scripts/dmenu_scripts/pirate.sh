#!/bin/sh

pirate_bay='https://thepiratebay10.org/search/'
movie=$(echo -e "\n" | dmenu -p "Pick a movie/series:" | sed 's/\ /\%20/g') || exit
curl "$pirate_bay$movie" > temp_page
magnets=$(cat temp_page | grep -Eoi '<a [^>]+>' | grep -Eo 'href="[^\"]+"' | grep -Eo 'magnet:.*')
marr=(`echo $magnets | tr ' ' ' '`)

titles=$(cat temp_page | 
         grep 'class="detLink"' | 
         sed -e "s//;/g" | 
         grep -o '<a.*>.*</a>;' | 
         sed 's/\(<a.*">\|<\/a>\)//g' |
         sed -E 's/\s/_/g')

arr=(`echo $titles | tr ';' ' '`)
choice=$(printf '%s\n' "${arr[@]}" | dmenu -i -l 20 -p 'Pick torrent:')
for x in ${!arr[@]}; do
    [[ "$choice" = "${arr[${x}]}" ]] && transmission-remote -a "${marr[${x}]}" && -RTMIN+7 dwmblocks
done
rm temp_page
