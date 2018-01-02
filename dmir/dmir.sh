#!/bin/bash
#
# dmir.sh
# Mirror a directory
# - Very simple wrapper around rsync to mirror directories
#
# Made by Zhu Zhan Yan.
# Copyright (c) 2016. All Rights Reserved.
#

## Programs ##
RSYNC=$(which rsync)

## Info ##
USAGE_INFO="Usage: dmir [-v -p -q -c -d -b] <SRC> <DEST>
-v          Produce verbose output.
-p          Display Transfer progress infomation.
-q          Do not produce non-error output.
-c          Use checksum to determine if file needs to transfered.
-d          Delete files that exists on DEST but not SRC.
-b          Backup Deleted and Modfied Files into DEST/.dmir_bkp
NOTE: Althrough dmir is a script, do not source it.
"
#TODO: -e exclude  Exclude Path from Transfer
RSYNC_OPT="--archive --update --exclude=.cache"
RSYNC_SRC=""
RSYNC_DEST=""
RSYNC_BKP=false
RSYNC_BKP_DIR=""

### Parse Arguments ###
while [ $# -ne 0 ]
do
    case $1 in
        -v)
             RSYNC_OPT="$RSYNC_OPT --verbose"
             shift
             ;;
        -p)
             RSYNC_OPT="$RSYNC_OPT --progress"
             shift
             ;;
        -q) 
             RSYNC_OPT="$RSYNC_OPT --quiet"
             shift
             ;;
        -c)
             RSYNC_OPT="$RSYNC_OPT --checksum"
             shift
             ;;
        -b)
             RSYNC_BKP=true
             shift
             ;;
        -d)
             RSYNC_OPT="$RSYNC_OPT --delete"
             shift
             ;;
        -*h*)
             printf "$USAGE_INFO"
             exit 0;
             shift
             ;;
        *)
             if [ $# -eq 2 -a -d "$1" -a -d "$2" ]
             then
                 RSYNC_SRC="$1/"
                 RSYNC_DEST="$2"
                 RSYNC_BKP_DIR="${RSYNC_DEST}/.dmir_bkp"
                 shift
                 shift
             elif [ $# -eq 2 ]
             then
                 printf "ERROR: Invaild Arguments\n" 1>&2
		 exit 1;
             else
                 printf "ERROR: Invaild Number of Arguments\n" 1>&2
                 exit 1;
             fi
             ;;
    esac
done

if $RSYNC_BKP
then
     RSYNC_OPT="$RSYNC_OPT --backup --backup-dir=$RSYNC_BKP_DIR"
     rm -rf "$RSYNC_BKP_DIR"
     mkdir "$RSYNC_BKP_DIR"
fi

### RUN RYNC ### 
exec $RSYNC $RSYNC_OPT "$RSYNC_SRC" "$RSYNC_DEST"
