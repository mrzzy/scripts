#
# dbkp.sh
# Yet Another RSYNC based backup script 
#

USAGE_INFO="Usage: dbkp [-qhnz] <src, src2, ...> <dest>
Produce a time stamped incremental backup of 'srcs' to 'dest', or if no prior 
backups exists in 'dest',perform a time stamped full backup.
Options: 
-v      Verbose output mode.
-h      Print this usage infomation
-n      Trial run, dont actually do anything
-z      Enable of compression to during transmittion 
-m      Mantain old backups
"

# Parse Arugments
SOURCES=""
DEST=""
RSYNC_OPT="--archive --one-file-system --safe-links --copy-unsafe-links --update --human-readable --hard-links --progress --stats --verbose --delete "

# Command Line Options
while getopts "vhnz" OPT
do
    case $OPT in 
        v)
            MODE_VERBOSE=true
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

if ! $MODE_VERBOSE; then RSYNC_OPT="$RSYNC_OPT --quiet"; fi

# Sources and destinations
if [ $# -lt 2 ]; then printf "No sources and destination given...\n"; exit 1; fi
while [ $# -gt 1 ]
do
    if [ ! -e  $SOURCES ]
    then 
        printf "Invalid: Nonexistent sources given...\n"
        exit 1
    fi

    SOURCES="$SOURCES $1"
    shift
done

if [ $# -lt 1  ]
then 
    printf "No destination given...\n"
    exit 1 
fi
DEST="$1"

if $MODE_VERBOSE
then
    printf "opt=$RSYNC_OPT\n" 
    printf "src=$SOURCES\n" 
    printf "dest=$DEST\n"
fi

# Hourly backups .%Y_%m_%d__%H
# Daily backups .%Y_%m_%d
# Monthly Backups .%Y_%m 

# Usage: ls_backup <src> <dest>  <type>
# List backups of 'src' in 'dest' of 'type' or '*' to specify all types
ls_backup()
{
    local SRC="$1"
    local DEST="$2"
    local TYPE="$3"

    local SRC_BASE="$(basename $1)"

    if [ "$TYPE" = '*' ]
    then
        local PREV_BKP_PATHS="$(ls_backup $SRC $DEST "hourly") $(ls_backup $SRC $DEST "daily") $(ls_backup $SRC $DEST "monthly")"
    elif [ "$TYPE" = "hourly" ]
    then
        local PREV_BKP_PATHS=$(find $DEST -maxdepth 1 -name $SRC_BASE'.????_??_??__??' -print)
    elif [ "$TYPE" = "daily" ]
    then
        local PREV_BKP_PATHS=$(find $DEST -maxdepth 1 -name $SRC_BASE'.????_??_??' -print)
    elif [ "$TYPE" = "monthly" ]
    then
        local PREV_BKP_PATHS=$(find $DEST -maxdepth 1 -name $SRC_BASE'.????_??' -print)
    fi

    # Basename-ify paths so that the dirname do not interfere with sorting 
    for BKP_PATH in $PREV_BKP_PATHS
    do 
        local PREV_BKPS="$PREV_BKPS $(basename $BKP_PATH)"
    done
    printf "$PREV_BKPS"
}

# Usage: backup <src> <dest> <type> 
# Backup with timestamp
# Perform backup of backup type - 'hourly','daily','monthly'
backup()
{
    local SRC="$1"
    local DEST="$2"
    local TYPE="$3"
    local SRC_BASE="$(basename $SRC)"

    # Name new backup based on backup type
    if [ "$TYPE" = "hourly" ]
    then
        local NEXT_BKP="$SRC_BASE.$(date +%Y_%m_%d__%H)"
    elif [ "$TYPE" = "daily" ]
    then
        local NEXT_BKP="$SRC_BASE.$(date +%Y_%m_%d)"
    elif [ "$TYPE" = "monthly" ]
    then
        local NEXT_BKP="$SRC_BASE.$(date +%Y_%m)"
    fi

    # Determine most recent old backup (if exists) to base new backup
    local PREV_BKPS="$(ls_backup $SRC $DEST '*' | tr ' ' '\n' | sort -r -k 2,2  -t '.')"
    local PREV_BKP="$(printf $PREV_BKPS | head -n 1 | sed -e 's/^[ ]*//')"

    # Perform backup with RSYNC
    if [ -z $PREV_BKP ]
    then 
        printf "[dbkp]: Performing full backup of $SRC...\n"
        if $MODE_VERBOSE; then printf "rsync $RSYNC_OPT $SRC $DEST/$NEXT_BKP\n";fi

        # Full Backup - entire copy of src
        rsync $RSYNC_OPT $SRC/ $DEST/$NEXT_BKP
    else
        printf "[dbkp]: Performing incremental backup of $SRC...\n"
        if $MODE_VERBOSE 
        then 
            printf "rsync $RSYNC_OPT --link-dest=\n"$DEST/$PREV_BKP" $SRC $DEST/$NEXT_BKP"
        fi

        # Incremental backup - hard link unchanged files, copy changed files
        rsync $RSYNC_OPT --link-dest="$DEST/$PREV_BKP" $SRC/ $DEST/$NEXT_BKP
    fi

    local STATUS=$?
    if [ $STATUS -ne 0 ]
    then # Backup did not complete sucessfully
        # Cleanup incomplete backup
        if $MODE_VERBOSE; then printf "rm -rf $DEST/$NEXT_BKP\n"; fi
        rm -rf $DEST/$NEXT_BKP
    fi
    return $?
}

# Usage: graduate <src> <dest> <tyoe>
# Graduate/Advance the most recent backup of 'src' in 'est' of the given 'type'
# its next type:
# hourly -> daily
# daily -> monthly
# monthly -> yearly
# If the graduating a backup would overwrite an existing backup, the action is 
# abandoned. For exmaple:
# if graduating 2018_03_02 to 2018_03 would overwrite existing backup 2018_03, 
# graduating would do nothing
graduate()
{
    local SRC="$1"
    local DEST="$2"
    local TYPE="$3"

    local UNGRAD_BKPS="$(ls_backup $SRC $DEST $TYPE | tr ' ' '\n' | sort -r -k 2,2  -t '.')"
    local UNGRAD_BKP="$(printf "$UNGRAD_BKPS" | head -n 1 )"
    
    #Check to see if there is anything to Graduate
    if  [ -z $(printf "$UNGRAD_BKP" | tr -d " ") ] 
    then
        if $MODE_VERBOSE; then printf "[dbkp]: Nothing to graduate.\n"; return 0; fi
    fi

    if [ "$TYPE" = "hourly" ] # -> daily
    then
        local GRAD_BKP="$(printf $UNGRAD_BKP | sed -e 's/__[0-9][0-9][ ]*$//')"
    elif [ "$TYPE" = "daily" ] # -> monthly
    then
        local GRAD_BKP="$(printf $UNGRAD_BKP | sed -e 's/_[0-9][0-9][ ]*$//')"
    elif [ "$TYPE" = "monthly" ] #-> yearly
    then
        local GRAD_BKP="$(printf $UNGRAD_BKP | sed -e 's/_[0-9][0-9][ ]*$//')"
    fi
    
    if [ -d "$DEST/$GRAD_BKP" ]
    then
        # Dont Graduate: Previous backup exists
        return -1;
    else
        if $MODE_VERBOSE; then 
            printf "mv $DEST/$UNGRAD_BKP $DEST/$GRAD_BKP\n"
            printf "ln -s $DEST/$GRAD_BKP $DEST/$UNGRAD_BKP\n"
        fi
        
        # Graduate: Move to new backup type, symlink old path to new
        # This allows the actual backup to be prune after/with its symlinks
        # And should not result in a situation where symlink points to a 
        # nonexistent backup
        mv  "$DEST/$UNGRAD_BKP" "$DEST/$GRAD_BKP" 
        ln -s "$DEST/$GRAD_BKP" "$DEST/$UNGRAD_BKP"

        return $?
    fi
}

# Usage: prune <src> <dest> <type> <keep> 
# Prune oldest backups of 'src' in 'dest' of the given 'type' - 'hourly','daily',
# 'monthly', keeping  the amount specified by 'keep'.
prune()
{
    local SRC="$1"
    local DEST="$2"
    local TYPE="$3"
    local KEEP="$4"

    # Check if current backups exceed keep quota
    local PREV_BKPS="$(ls_backup $SRC $DEST $TYPE | tr ' ' '\n' | sort -r -k 2,2  -t '.')"
    if [ $(printf "$PREV_BKPS" | wc -w) -le $KEEP ]; then return 0; fi
    
    # Determine oldest backups outside of the keep quota 
    if [ $KEEP -gt 0 ]
    then  
        local PRUNE_BKPS=$(printf "$PREV_BKPS" | tr ' ' '\n')
        
        printf "$PRUNE_BKPS" | tail -n +"$KEEP"
    else 
        PRUNE_BKPS="$PREV_BKPS"
    fi
    
    # Prune old backups
    for PRUNE_BKP in $PRUNE_BKPS
    do
        # Prune symlinks to actual backups
        # Check if really a backup, not symbolic link
        if  [ ! -L "$PRUNE_BKP" ] && [ -d "$PRUNE_BKP" ] 
        then 
            local PRUNE_LINKS="$(find -L $DEST -maxdepth 1 -samefile $DEST/$PRUNE_BKP)"

            for PRUNE_LINK in $PRUNE_LINKS
            do
                if [ -L "$PRUNE_LINK" ] # Dont delete the actual backup itself
                then
                    if $MODE_VERBOSE; then printf "rm $DEST/$PRUNE_LINK\n"; fi
                    rm "$DEST/$PRUNE_LINK"
                fi
            done
        fi

        if $MODE_VERBOSE; then printf "rm -rf $DEST/$PRUNE_BKP\n"; fi
        rm -rf "$DEST/$PRUNE_BKP"
    done
}

for SRC in $SOURCES
do
    # Perform backup of current
    backup "$SRC" "$DEST" "hourly"
    if [ $? -ne 0 ]
    then
        printf "\033[1m\033[0;31m[dbkp]: Backup failed.\033[0m\n"
        exit 1
    else
        printf "\033[1m\033[0;32m[dbkp]: Backup complete.\033[0m\n"
    fi

    # Prune old backups
    prune "$SRC" "$DEST" "hourly" 24
    prune "$SRC" "$DEST" "daily" 20
    prune "$SRC" "$DEST" "monthly" 18
    
    # Graduate backups
    graduate "$SRC" "$DEST" "hourly" # to daily
    graduate "$SRC" "$DEST" "daily" # to monthly
done
