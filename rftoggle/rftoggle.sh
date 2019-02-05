#!/bin/sh
#
# rftoggle.sh
# RFKill, But Toggle
#

# Toggle target rfkill
TARGET=$1
if [ $(rfkill | grep $TARGET | head -n 1 | awk '{print $4}') = 'unblocked' ]
then
    rfkill block $TARGET
else
    rfkill unblock $TARGET
fi
