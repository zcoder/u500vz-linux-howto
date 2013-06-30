#!/usr/bin/env bash
cd $(dirname $0);
current=$(cat keyboard-brightness-state)
echo $current > /sys/class/leds/asus::kbd_backlight/brightness
