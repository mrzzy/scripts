#!/bin/bash
#
# gswitch.sh
# Switch between Nvidia and Intel Graphics using system76-power
# with graphics screen tearing fixes
#

# Check user privilleges
if [ $EUID -ne 0 ]
then
    echo "You must be root to run this. try sudo gswitch"
    exit 1
fi

# Check arguments
if [ -z "$1" ]
then
    echo "current: $(system76-power graphics) graphics"
    exit 
fi

TARGET=$1
if [ $(system76-power graphics) = $1 ]
then
    echo "no switch required."
    exit 0
fi

# Perform graphics switch
system76-power graphics $1
if [ $? -ne 0 ]
then
    echo "failed to switch graphics"
    exit 1
else
    echo "switched to: $1 graphics" 
fi

# Insert graphics screen tearing fix for specific graphics
## Intel fix works by inserting xorg config with TearFree option set
INTEL_FIX_PATH="/etc/X11/xorg.conf.d/20-intel_graphics.conf"
if [ $TARGET = "intel" ]
then
    cat > $INTEL_FIX_PATH << EOF
#
# 20-intel_graphics.conf
# gswitch Fix for Screen Tearing
# Autogenerated by gswitch
# 

Section "Device"
    Identifier "Intel Graphics"
    Driver "intel"
    Option "TearFree" "true"
EndSection
EOF
    echo "inserted: screen tear fix for intel graphics"
else
    rm -f $INTEL_FIX_PATH
    echo "removed: screen tear fix for intel graphics"
fi

## Nvidia fix works by setting modeset=1 for nvidia_drm kernel options
## then updating the kernel with said options
NVIDIA_FIX_PATH="/etc/modprobe.d/zz-nvidia-modeset.conf"
if [ $TARGET = "nvidia" ]
then
    # Insert fix
    cat > $NVIDIA_FIX_PATH << EOF
#
# zz-nvidia-modeset.conf
# gswitch Fix for Nvidia Screen Tearing
# Autogenerated by gswitch
#

options nvidia_drm modeset=1
EOF
    # Update kernel with inserted fix
    update-initramfs -u &>/dev/null
    echo "inserted: screen tear fix for nvidia graphics"
else
    # Remove fix
    rm -rf $NVIDIA_FIX_PATH
    
    # Update kernel with fix removed
    update-initramfs -u &>/dev/null
    echo "removed: screen tear fix for nvidia graphics"
fi