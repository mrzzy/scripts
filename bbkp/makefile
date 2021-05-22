#
# makefile
# Makefile for bbkp
#

# check required variables are set
ifndef BORG_REPO
$(error BORG_REPO make variable should be set)
endif

ifndef BORG_PASSPHRASE
$(error BORG_PASSPHRASE make variable should be set)
endif

## Programs ##
CP:=cp -f
ENV:=env
ENVSUBST:=envsubst
RM=rm -rf
CHMOD=chmod
MKDIR=mkdir -p
PYTHON:=python3
PIP:=$(PYTHON) -m pip
SYSTEMCTL:=systemctl

### Rules ### 
.PHONY: install uninstall

install: requirements.txt /etc/borgmatic/config.yaml /etc/systemd/system/borgmatic.service /etc/systemd/system/borgmatic.timer
	$(PIP) install -r $<
	validate-borgmatic-config
	$(SYSTEMCTL) daemon-reload 
	$(SYSTEMCTL) enable borgmatic.timer

uninstall:
	$(RM) /etc/borgmatic
	$(SYSTEMCTL) disable borgmatic.timer
	$(RM) /etc/systemd/system/borgmatic.service
	$(RM) /etc/systemd/system/borgmatic.timer
	$(SYSTEMCTL) daemon-reload 

## file targets
# copy config borg config variables set
/etc/borgmatic/config.yaml: borgmatic.yaml
	$(MKDIR) $(dir $@)
	@cat $< | $(ENV) \
		BORG_REPO=$(BORG_REPO) \
		BORG_PASSPHRASE=$(BORG_PASSPHRASE) \
		$(ENVSUBST) >$@

# systemd service for scheduling jobs
/etc/systemd/system/borgmatic.%: borgmatic.%
	$(CP) $< $@
