#
# makefile
# imgopt makefile
#
SOURCE:=./img_opt.py
PRODUCT:=/usr/local/bin/imgopt

install: $(PRODUCT)
	
.PHONY: install uninstall

uninstall:
	rm $(PRODUCT)
	
$(PRODUCT): $(SOURCE)
	cp $< $@
	chmod a+rx $@
