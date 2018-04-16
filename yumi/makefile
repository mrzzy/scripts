#
# makefile 
# Yumi Makefile 

.PHONY: install remove config

TARGETS=/usr/local/bin/yumi ~/.yumi.conf

install: $(TARGETS)

remove:
	rm $(TARGETS)

config: ~/.yumi.conf

/usr/local/bin/yumi:
	cp yumi.sh $@
	chmod a+rx $@

~/.yumi.conf:
	sh yumi_config.sh
