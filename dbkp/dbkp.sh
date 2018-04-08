#
# dbkp.sh
# Yet Another RSYNC based backup script 
#

USAGE_INFO="Usage: dbkp [-cpq] <src, src2, ...> <dest>
Produce a time stamped incremental backup of 'srcs' to 'dest', or if no prior 
backups exists in 'dest', perform a time stamped full backup
Options: 
-q      Super slient stealth mode, only print error messages
-h      Print this usage infomationb
-n      Trial run, dont actually do anything
-z      Enable of compression to during transmittion 
"

# Parse Arugments
SOURCES=""
DEST=""
RSYNC_OPT="-ah --checksum --hard-links --progress --stats --verbose --delete"

# Command Line Options
while getopts "qhnz" OPT
do
    case $OPT in 
        q)
            RSYNC_OPT="$RSYNC_OPT --quiet"
            MODE_QUIET=true
        ;;
        n)
            RSYNC_OPT="$RSYNC_OPT -n"
        ;;
        z)
            RSYNC_OPT="$RSYNC_OPT -z"
        ;;
        h)
            printf "$USAGE_INFO"
            exit 0
        ;;
    esac
done
shift $((OPTIND-1))

# Sources and destinations
if [ $# -lt 2 ]; then printf "No sources and destination given...\n"; exit 1; fi
while [ $# -gt 1 ]
do
    SOURCES="$SOURCES $1"
    shift
done

if [ $# -lt 1 ]; then printf "No destination given...\n"; exit 1; fi
DEST="$1"

echo "opt=$RSYNC_OPT" 
echo "src=$SOURCES" 
echo "dest=$DEST" 

# Backup with timestamp
for SRC in $SOURCES
do
    NEXT_BKP="$(basename $SRC).$(date +%Y_%m_%d__%H_%M)"
    printf "\033[1m\033[0;32m[dbkp]: Backing up $SRC as $NEXT_BKP .... \033[0m\n"

    # Find previous backup as base for new backup
    PREV_BKP_PATHS="$(find $DEST -maxdepth 2 -type d -name $SRC'.????_??_??__??_??' -print)"
    PREV_BKPS=""

    for BKP_PATH in $PREV_BKP_PATHS
    do PREV_BKPS="$PREV_BKPS
        $(basename $BKP_PATH)"
    done
    PREV_BKP="$(printf "$PREV_BKPS" | sort -rt "." | head -n 1  | sed -e 's/^[ \t]*//')"
    
    
    # Perform backup with RSYNC
    if [ -z $PREV_BKP ]
    then 
        echo rsync $RSYNC_OPT $SRC $DEST/$NEXT_BKP
        rsync $RSYNC_OPT $SRC $DEST/$NEXT_BKP
    else
        echo rsync $RSYNC_OPT --link-dest=$DEST/$PREV_BKP $SRC $DEST/$NEXT_BKP
        rsync $RSYNC_OPT --link-dest="../$PREV_BKP" $SRC $DEST/$NEXT_BKP
    fi
done
