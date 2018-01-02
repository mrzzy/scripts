#!/bin/bash
# svncsvr
# Secure VNC Server (Wrapper)
#
# Made by Zhu Zhan Yan
#

## Programs ##
PRG_VNC_SVR="x11vnc"

## Info ##
INFO_USAGE="Usage: svncsvr [-d :<display>] [-g <widthxheight>] [-k]
-d display       Display to run server on
-g widthxheight  Set dessktop width and height
-k               kill server on display"

## Data ###
VNC_DISPLAY="-display :0"
if xset q &>/dev/null; then
VNC_GEOMETRY="-geometry $(xrandr | fgrep '*' | sed -e 's/^[^0-9]*\([0-9]*x[0-9]*\).*$/\1/g')"
else
VNC_GEOMETRY=""
fi
VNC_OPT="-nopw -create -forever -alwaysshared -localhost -xkb"
VNC_KILL=false

### Parse Arguemnts ###
while  [ $# -ne 0 ]
do
    case $1 in
        -d )
            VNC_DISPLAY="$2"
            shift 2 
            ;;

        -g)
            VNC_GEOMETRY="-geometry $2"
            shift 2
            ;;
        -k)
            VNC_KILL=true
            shift
            ;;
        -h)
            echo $INFO_USAGE
            exit 0
            ;;
        *)
            printf "FATAL: Unknown argument $1\n" 1>&2
            exit 1
            ;;
    esac
done

### RUN Server ###
if ! $VNC_KILL
then
    $PRG_VNC_SVR $VNC_DISPLAY $VNC_GEOMETRY $VNC_OPT
else
    $PRG_VNC_SVR -kill $VNC_DISPLAY
fi
