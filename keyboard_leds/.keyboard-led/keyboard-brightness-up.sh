#!/usr/bin/env bash
cd $(dirname $0);
current=$(cat keyboard-brightness-state)
if [[ $current -lt 3 ]]
then
let 'current += 1'
echo $current > keyboard-brightness-state
echo $current > /sys/class/leds/asus::kbd_backlight/brightness
fi;
