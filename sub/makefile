#
# makefile
# Makefile for Sub
#

## Programs ##
CP=cp -f
RM=rm -rf
CHMOD=chmod

## Files ##
SRC=sub.pl
PDCT=/usr/local/bin/sub

### Rules ### 
.PHONY: install uninstall

install: $(PDCT)

uninstall:
	$(RM) $(PDCT)

$(PDCT): $(SRC)
	$(CP) $< $@
	$(CHMOD) a+rx $@
