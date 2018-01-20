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
	@printf "YURL Server:"
	@read SERVER
	@printf "\n"
	@printf "YURL Signature:"
	@read SIGNATURE
	@printf "\n"
	printf "server: %s\nsignature: %s\n" >~$@
	@printf "Done. To reconfigure yurl, run 'make config'\n"
