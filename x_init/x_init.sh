#
# x_init.sh
# Start X on Login
#
# Made by Zhu Zhan Yan.
# Copyright (c) 2016. All Rights Reserved.
# 

if [ ! $USER = "root" -a -n $PS1 ] && [ -z "$SSH_CLIENT" -a -z "$SSH_TTY" ]  && ! xset q &>/dev/null
then
    startx
fi
