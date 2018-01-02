#
# makefile
# Makefile for X_Init
# 
# Made by Zhu Zhan Yan.
# All rights reserved. Copyright (c) 2016.
# 

## Programs ##
CP=cp -f
RM=rm -f

## Files ##
SRC=x_init.sh
PDCT=/etc/profile.d/x_init.sh

## Rules ##
.PHONY: install uninstall

$(PDCT): $(SRC)
	$(CP) $< $@

install: $(PDCT)

uninstall:
	$(RM) $(PDCT)
