#
# makefile
# Makefile for DBKP
#

## Programs ##
CP=cp -f
RM=rm -rf
CHMOD=chmod

## Files ##
SRC=dbkp.sh
PDCT=/usr/local/bin/dbkp

### Rules ### 
.PHONY: install uninstall

install: $(PDCT)

uninstall:
	$(RM) $(PDCT)

$(PDCT): $(SRC)
	$(CP) $< $@
	$(CHMOD) a+rx $@
