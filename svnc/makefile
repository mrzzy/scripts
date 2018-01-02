#
# makefile
# Makefile for SVNC
#
# Made by Zhu Zhan Yan.
# Copyright (c) 2016. All Rights Reserved.
#

## Programs ##
CP=cp -f
RM=rm -rf
CHMOD=chmod

## Files ##
PDCT=/usr/bin/svncclt /usr/sbin/svncsvr /etc/init.d/svncsvr

### Rules ###
.PHONY: install uninstall

install: $(PDCT)

uninstall: $(PDCT)
	$(RM) $(PDCT)
	
$(word 1,$(PDCT)): $(notdir $(word 1,$(PDCT))).sh
	$(CP) $< $@

$(word 2,$(PDCT)): $(notdir $(word 2,$(PDCT))).sh
	$(CP) $< $@

$(word 3,$(PDCT)): $(notdir $(word 2,$(PDCT))).init
	$(CP) $< $@
