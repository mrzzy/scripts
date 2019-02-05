#
# makefile
# Makefile for gswitch
#

## Programs ##
CP=cp -f
RM=rm -rf
CHMOD=chmod

## Files ##
SRC=gswitch.sh
PDCT=/usr/local/bin/gswitch

### Rules ### 
.PHONY: install uninstall

install: $(PDCT)

uninstall:
	$(RM) $(PDCT)

$(PDCT): $(SRC)
	$(CP) $< $@
	$(CHMOD) a+rx $@
