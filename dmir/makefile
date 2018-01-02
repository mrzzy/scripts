#
# makefile
# Makefile for Dmir
#
# Made by Zhu Zhan Yan.
# Copyright (c) 2016. All Rights Reserved.
#

## Programs ##
CP=cp -f
RM=rm -rf
CHMOD=chmod

## Files ##
SRC=dmir.sh
PDCT=/usr/local/bin/dmir

### Rules ### 
.PHONY: install uninstall

install: $(PDCT)

uninstall:
	$(RM) $(PDCT)

$(PDCT): $(SRC)
	$(CP) $< $@
	$(CHMOD) a+rx $@
