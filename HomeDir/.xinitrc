# swap caps and ctrl
# setxkbmap -option ctrl:swapcaps
setxkbmap us
# run key click
sxhkd&
# add application mapper
# to debug, kill process first keyd-application-mapper -v
keyd-application-mapper -d
# merge xresource
xrdb -merge ~/.config/X11/.Xresources
# start i3
# exec i3
# start Hyprland
exec Hyprland
