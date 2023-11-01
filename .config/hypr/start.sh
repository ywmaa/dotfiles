#!/usr/bin/env bash

# init wallpaper daemon
swww init &
# setting wallpaper
swww img ~/.wallpapers/wallhaven-2560x1440.png &


# pkgs.networkmanagerapplet
nm-applet --indicator &

# the bar
waybar &

# dunst
dunst

