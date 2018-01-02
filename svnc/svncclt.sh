#!/bin/bash
#
# svncclt.sh
# Secure VNC Client
# 
# Made by Zhu Zhan Yan.
# Copyright (c) 2016. All Rights Reserved.
#

## Programs ##
PRG_VNC_VWR="vncviewer"
PRG_SSH="ssh -fN"

## Info ##
INFO_USAGE="Usage: svncclt [-v] [-c <level>] [-q <quality>] [-d <display>]
 [user] host
-v          Disable transfer of keyboard and mouse events
-c level    Set compression level (0-9)
-q quality  Set transmission quality (0-9)
-d display  Display to connect to.
-p port     Port to use when creating ssh tunnel
"

## Data ##
VNC_DISPLAY="0"
VNC_COMP_LVL="9"
VNC_QLT_LVL="7"
VNC_OPT="-truecolor -autopass"
VNC_ENCODINGS="Tight"
SSH_USR="$USER"
SSH_LHOST="127.0.0.1"
SSH_RHOST=""
SSH_RCPORT="22"
SSH_LPORT="5000$VNC_DISPLAY"
SSH_RPORT="590$VNC_DISPLAY"
SSH_CIPHER="arcfour"
SSH_OPT=""

### Parse Arguemnts ###
while [ $# -ne 0 ]
do
    case "$1" in
        -v)
            VNC_OPT="$VNC_OPT -viewonly"
            shift
            ;;
        -c)
            VNC_COMP_LVL="$2"
            shift 2
            ;;
        -q)
            VNC_COMP_QLT="$2"
            shift 2
            ;;
        -d)
            VNC_DISPLAY="$2"
            SSH_RPORT="590$2";
            shift 2
            ;;
        -p)
            SSH_CPORT="$2"
            shift 2
            ;;  
        -h)
            echo $INFO_USAGE
            ;;
        *)
            if [ $# -eq 1 ] 
            then
                SSH_RHOST="$1"
                shift
            elif [ $# -eq 2 ]
            then
                SSH_USR="$1"
                SSH_RHOST="$2"
                shift 2
            else
                print "FATAL: Unknown argument $1\n" 1>&2
                exit 1
            fi
            ;;
    esac
done
if [ -z $SSH_RHOST ]
then
    printf "FATAL: Missing argument host \n" 1>&2
    exit 1
fi
    

### RUN Programs ###
$PRG_SSH $SSH_OPT -c $SSH_CIPHER -l $SSH_USR -L $SSH_LPORT:$SSH_LHOST:$SSH_RPORT $SSH_RHOST
$PRG_VNC_VWR $VNC_OPT -encodings $VNC_ENCODINGS -quality $VNC_QLT_LVL -compresslevel $VNC_COMP_LVL $SSH_LHOST::$SSH_LPORT
