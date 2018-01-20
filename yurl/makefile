#
# makefile 
# Yurl Makefile
#

.PHONY: install remove config

TARGETS=/usr/local/bin/yurl ~/.yurl.conf

install: $(TARGETS)

remove:
	rm $(TARGETS)

config: ~/.yurl.conf

/usr/local/bin/yurl:
	cp yurl.sh $@
	chmod a+rx $@

~/.yurl.conf:
	@printf "Setup Configuration for YURL\n"
	@sh -c "printf 'YURL Server: '; read SERVER; printf 'YURL Signature: '; read SIGNATURE; printf 'server: %s\nsignature: %s\n' "$$SERVER" "$$SIGNATURE" >$@"
	@printf "Done. To reconfigure yurl, run 'make remove && make config'\n"
