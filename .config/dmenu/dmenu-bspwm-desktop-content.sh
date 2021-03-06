#!/bin/sh

dmenu_string="Wrong parameter"

case $1 in
    "goto")
        dmenu_string="Switch to desktop: " ;;
    "move")
        dmenu_string="Move node to desktop: " ;;
    "movefollow")
        dmenu_string="Move and follow node to desktop: " ;;
esac

desktop=$(bspc query -m focused -D --names | dmenu -p "$dmenu_string")

found=false

desktop_list=$(bspc query -m focused -D --names | tr '\n' ' ')

if [[ $desktop != "" ]];
then
    for name in $desktop_list; do
        if [[ $name == $desktop ]]; then
            found=true
        fi
    done
fi

if [ ! $found = true ]; then
    bspc monitor -d $desktop_list $desktop
fi

case $1 in
    "goto")
        bspc desktop -f $desktop ;;
    "move")
        bspc node -d $desktop ;;
    "movefollow")
        bspc node -d $desktop --follow ;;
esac
