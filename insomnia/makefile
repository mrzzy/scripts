#
# makefile
# Makefile for Insomnia
#
# Made by Zhu Zhan Yan.
# Copyright (c) 2016. All Rights Reserved.
#

SRC=insomnia.pl
PDCT=/usr/local/bin/$(patsubst %.pl,%,$(SRC))

.PHONY: install uninstall

install: $(SRC)
	cp -f $< $(PDCT)

uninstall: $(PDCT)
	rm -rf $(PDCT)
