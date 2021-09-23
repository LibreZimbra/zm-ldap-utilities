ANT ?= ant
ZIMBRA_PREFIX ?= /opt/zimbra

all:
	$(ANT) build-dist

install:
	mkdir -p $(DESTDIR)$(ZIMBRA_PREFIX)/conf \
		 $(DESTDIR)$(ZIMBRA_PREFIX)/conf/externaldirsync \
		 $(DESTDIR)$(ZIMBRA_PREFIX)/libexec/scripts \
		 $(DESTDIR)$(ZIMBRA_PREFIX)/common/etc/openldap/zimbra \
		 $(DESTDIR)/etc/sudoers.d/

	cp conf/externaldirsync/*.xml      $(DESTDIR)$(ZIMBRA_PREFIX)/conf/externaldirsync
	cp src/ldap/migration/*.pl         $(DESTDIR)$(ZIMBRA_PREFIX)/libexec/scripts
	cp conf/zmconfigd.cf               $(DESTDIR)$(ZIMBRA_PREFIX)/conf
	cp conf/zmconfigd.log4j.properties $(DESTDIR)$(ZIMBRA_PREFIX)/conf
	cp src/libexec/zm*                 $(DESTDIR)$(ZIMBRA_PREFIX)/libexec
	cp -r build/ldap-config/*          $(DESTDIR)$(ZIMBRA_PREFIX)/common/etc/openldap/zimbra
	cp etc/sudoers.d/02_zimbra-ldap    $(DESTDIR)/etc/sudoers.d
	chmod 440 $(DESTDIR)/etc/sudoers.d/02_zimbra-ldap

clean:
	rm -Rf build
