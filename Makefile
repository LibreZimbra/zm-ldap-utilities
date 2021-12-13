# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (C) Enrico Weigelt, metux IT consult <info@metux.net>

all: build

include build.mk

build:
	$(ANT) build-dist $(ANT_ARG_BUILDINFO) \
                          -Dattr.config.dir=$(ZIMBRA_PREFIX)/conf # taken from installed mbox package

SCHEMA_DIR := $(INSTALL_DIR)/common/etc/openldap/config/cn=config/cn=schema

install:
	$(call mk_install_dir, conf/externaldirsync)
	$(call mk_install_dir, libexec/scripts)
	$(call mk_install_dir, common/etc/openldap)

	mkdir -p $(DESTDIR)/etc/sudoers.d/

	cp conf/externaldirsync/*.xml      $(INSTALL_DIR)/conf/externaldirsync
	cp src/ldap/migration/*.pl         $(INSTALL_DIR)/libexec/scripts
	cp src/libexec/zm*                 $(INSTALL_DIR)/libexec
	cp -r build/ldap-config/*          $(INSTALL_DIR)/common/etc/openldap
	cp etc/sudoers.d/02_zimbra-ldap    $(DESTDIR)/etc/sudoers.d
	chmod 440 $(DESTDIR)/etc/sudoers.d/02_zimbra-ldap

	$(call install_conf, conf/ldap/slapd.conf)

	cp build/dist/schema/zimbra.ldif $(INSTALL_DIR)/common/etc/openldap/schema

clean:
	rm -Rf build
