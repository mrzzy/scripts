#!/bin/sh
#
# yumi.sh
# YUMI - YoUrls Manipulation Interface
#

USAGE="Usage: yumi [-fdx] [-t <server>] [-s <signature>] [-m <destination>] <keyword/shorturl...>.
-f - force action, even if it means that the action is destructive
-x - expand shortened url by 'keyword' or 'shorturl' to its long form.
-d - delete url shortcut by the name of 'keyword' or 'shorturl'
-m - map 'destination' url to shortened url by 'keyword' or 'shorturl'
-s - set persitent signature key to use when querying the YourURL server
-t - set persitent target yourURL server to query.
-h - print this usage infomation
"

SERVER=
SIGNATURE=

die()
{
    echo "Error: $1" >&2
    exit 1
}

#Load Configuration
CONFIG_PATH="$HOME/.yumi.conf"
parse_config()
{
    PARAMETER=$1
    WHITESPACE=' 	'
    sed -n "/$PARAMETER:/s/[$WHITESPACE]*$PARAMETER:[$WHITESPACE]*\([.0-9a-zA-Z]*\)[$WHITESPACE]*/\1/p" $CONFIG_PATH | tr -d '\n'
}

update_config()
{
    PARAMETER=$1
    VALUE=$2

    sed -n "/$PARAMETER:/s/[$WHITESPACE]*$PARAMETER:[$WHITESPACE]*\([.0-9a-zA-Z]*\)[$WHITESPACE]*/$VALUE/p" $CONFIG_PATH  >"$CONFIG_PATH.tmp"
    mv "$CONFIG_PATH.tmp" $CONFIG_PATH
    rm "$CONFIG_PATH.tmp"
}

if [ -f $CONFIG_PATH ]
then
    SERVER=$(parse_config 'server')
    SIGNATURE=$(parse_config 'signature')
fi

#Parse Optionns
FORCE=false
ACTION="expand" #Default Action: Expand Short URL

MAP_DEST=

while getopts "hfdxt:s:m:" OPT; do
    case $OPT in
        h)
            echo "$USAGE"
            exit 0
        ;;
        f)
            FORCE=true;
        ;;
        d) 
            ACTION="delete"
        ;;
        x) 
            ACTION="expand"
        ;;
        t)
            SERVER=$OPTARG
            update_config 'server' "$OPTARG"
        ;;
        s)
            SIGNATURE=$OPTARG
            update_config 'signature' "$OPTARG"
        ;;
        m)
            ACTION="map"
            MAP_DEST=$OPTARG
        ;;
        ?)
            echo "$USAGE"
            exit 1
        ;;
    esac
done

shift $((OPTIND -1))
if [ -z $1 ]; then die "Missing argument: shorturl or keyword"; fi

ERRNO_OK=0
ERRNO_DEFINED=3
ERRNO_NETWORK=2
ERRNO_NOTFOUND=1

RESULT=
expand_shorturl()
{
    SHORTURL_REF=$1
    REPLY=`curl --max-time 5 -G -s "http://$SERVER/yourls-api.php?signature=$SIGNATURE&action=expand&shorturl=$SHORTURL_REF&format=simple"`
    if [ $? -ne 0 ]; then return $ERRNO_NETWORK
    elif [ "$REPLY" = 'not found' ]
    then return $ERRNO_NOTFOUND
    else 
        RESULT="$REPLY"
        return $ERRNO_OK;
    fi
}

delete_shorturl()
{
    SHORTURL_REF=$1
    REPLY=`curl --max-time 5 -G -s "http://$SERVER/yourls-api.php?signature=$SIGNATURE&action=delete&shorturl=$SHORTURL_REF&format=simple"`
    if [ $? -ne 0 ]; then return $ERRNO_NETWORK
    elif [ -z "$REPLY" ]
    then return $ERRNO_NOTFOUND
    else return $ERRNO_OK;
    fi
}

map_shorturl()
{
    TARGET=$1
    SHORTURL_REF=$2
    REPLY=`curl --max-time 5 -G -s --data-urlencode "url=$TARGET" "http://$SERVER/yourls-api.php?signature=$SIGNATURE&action=shorturl&keyword=$SHORTURL_REF&format=simple"`
    REPLY_REF=`printf "$REPLY" | sed -e "s:^.*/::" | tr -d '\n'`
    if [ $? -ne 0 ]; then return $ERRNO_NETWORK
    elif [ -z "$REPLY" ]; then return $ERRNO_DEFINED
    elif ! [ "$SHORTURL_REF" = "$REPLY_REF" ]; then return $ERRNO_DEFINED
    else 
        RESULT="$REPLY"
        return $ERRNO_OK;
    fi
}

for REF in $@
do
    KEYWORD=`printf "$REF" | sed -e "s:^.*/::"`
    case $ACTION in
        'expand')
            expand_shorturl "$KEYWORD"
            CODE=$?
        ;;
        'delete')
            delete_shorturl "$KEYWORD"
            CODE=$?
        ;;
        'map')
            if $FORCE
            then
                delete_shorturl "$KEYWORD"
            fi

            map_shorturl "$MAP_DEST" "$KEYWORD" 
            CODE=$?
        
            if $FORCE && [ $CODE -eq $ERRNO_DEFINED ]
            then
                DELETE_SURL=`printf "$REPLY" | sed -e "s:^.*/::" | tr -d '\n'`
                delete_shorturl "$DELETE_SURL"

                CODE=$?
            fi
        ;;
    esac

    if [ $CODE -eq $ERRNO_NETWORK ]
    then die "Network Operation Failed"
    elif [ $CODE -eq $ERRNO_NOTFOUND ]
    then die "Short Url $SHORTURL_REF not found on server $SERVER"
    elif [ $CODE -eq $ERRNO_DEFINED ]
    then 
        die "Short URL or Destination URL already mapped on server $SERVER.
        Use -f to force"
    elif [ -n "$RESULT" ]
    then printf "%s\n"  $RESULT;
    fi
done
