#
# makefile
# Makefile for DBKP
#

## Programs ##
CP=cp -f
RM=rm -rf
CHMOD=chmod

## Files ##
SRC=rftoggle.sh
PDCT=/usr/local/bin/rftoggle

### Rules ### 
.PHONY: install uninstall

install: $(PDCT)

uninstall:
	$(RM) $(PDCT)

$(PDCT): $(SRC)
	$(CP) $< $@
	$(CHMOD) a+rx $@
