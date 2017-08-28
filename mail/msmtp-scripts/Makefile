#
# Copyright (C) 2009 David Cooper <dave@kupesoft.com>
# Copyright (C) 2009-2015 OpenWrt.org
# Copyright (C) 2016 Daniel Dickinson <lede@daniel.thecshore.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=msmtp-scripts
PKG_VERSION:=1.0.8
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/msmtp-scripts
PKG_HASH:=2aec48d47b02facf2a33cf97a7434e969c1a054224406e6c55320d825c7902b2

PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Daniel Dickinson <lede@daniel.thecshore.com>

include $(INCLUDE_DIR)/package.mk

define Package/msmtp-scripts/Default
  SECTION:=mail
  CATEGORY:=Mail
  TITLE:=Simple sendmail SMTP queueing and forwarding
  URL:=http://msmtp-scripts.sourceforge.net/
endef

define Package/msmtp-scripts/Default/description
 msmtp-scripts are scripts wrappers around the msmtp SMTP client that
 add queueing, logging to syslog or file, a subset of sendmail/postfix
 mailq/postsuper/postqueue commands implemented in a compatible fashion.
endef

define Package/msmtpq-ng
$(call Package/msmtp-scripts/Default)
  DEPENDS+= @(PACKAGE_msmtp||PACKAGE_msmtp-nossl)
  TITLE+= (msmtpq-ng wrappers)
endef

define Package/msmtpq-ng/conffiles
/etc/msmtpq-ng.rc
endef

define Package/msmtpq-ng/description
 $(call Package/msmtp-scripts/Default/description)
 This package contains the msmtpq-ng and msmtpq-ng-queue
 wrappers around msmtp, which provide the bulk of the
 functionality.
endef

define Package/msmtpq-ng-mta
$(call Package/msmtp-scripts/Default)
  TITLE+= (as MTA)
  DEPENDS+=+msmtpq-ng
  USERID:=msmtp=482:msmtp=482
endef

define Package/msmtp-queue-mta/conffiles
/etc/msmtpq-ng-mta.rc
endef

define Package/msmtpq-ng-mta/description
 $(call Package/msmtp-scripts/Default/description)
 This package provides sendmail, mailq, postfix,
 and postsuper symlinks to wrappers that configure
 msmtpq-ng for use as the system mail transport
 agent via the sendmail command.
endef

define Package/msmtpq-ng-mta-smtpd
$(call Package/msmtp-scripts/Default)
  DEPENDS+= +msmtpq-ng-mta +xinetd
  TITLE+= (basic SMTP server)
endef

define Package/msmtp-ng-mta-smtpd/description
 $(call Package/msmtp-scripts/Default/description)
 This package uses the -bs option to msmtpq-ng
 (which, like the sendmail -bs command, provides
 SMTP over stdin/stdout) combined with xinetd to
 provide a basic SMTP server.  In it's default
 configuration it only accepts connections from
 localhost AND network mail must be released from
 the hold queue before it can be delivered.
endef

define Package/msmtpq-ng-mta/postinst
	mkdir -p $${IPKG_INSTROOT}/etc/crontabs
	if ! grep -q msmtpq-ng-mta $${IPKG_INSTROOT}/etc/crontabs/root; then echo $$'\n'"*/60 * * * * /usr/bin/msmtpq-ng-mta -q" >>$${IPKG_INSTROOT}/etc/crontabs/root; fi
endef

define Package/msmtp-queue-mta/prerm
	if grep -q msmtpq-ng-mta $${IPKG_INSTROOT}/etc/crontabs/root; then grep -v '\*/60 \* \* \* \* /usr/bin/msmtpq-ng-mta -q' $${IPKG_INSTROOT}/etc/crontabs/root >$${IPKG_INSTROOT}/etc/crontabs/root.new; mv -f $${IPKG_INSTROOT}/etc/crontabs/root.new $${IPKG_INSTROOT}/etc/crontabs; fi
endef

define Build/Configure
	true
endef

define Build/Compile
	true
endef

define Package/msmtpq-ng/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/msmtpq-ng.rc $(1)/etc/msmtpq-ng.rc
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/msmtpq-ng/msmtpq-ng $(1)/usr/bin/
	$(SED) 's/logger -i/logger/' $(1)/usr/bin/msmtpq-ng
	$(CP) $(PKG_BUILD_DIR)/msmtpq-ng/msmtpq-ng-queue $(1)/usr/bin/
endef

define Package/msmtpq-ng-mta/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/sbin $(1)/usr/lib $(1)/etc/init.d
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/msmtpq-ng-mta/msmtpq-ng-mta.rc $(1)/etc/
	echo 'MSMTP_LOCK_DIR=/var/lock/msmtp' >>$(1)/etc/msmtpq-ng-mta.rc
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/msmtpq-ng-mta/msmtpq-ng-mta $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/msmtpq-ng-mta/msmtpq-ng-queue-mta $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/crontabs
	$(INSTALL_BIN) ./files/msmtpq-ng-mta.init $(1)/etc/init.d/msmtpq-ng-mta
	ln -sf ../bin/msmtpq-ng-mta $(1)/usr/sbin/sendmail
	ln -sf ../bin/msmtpq-ng-mta $(1)/usr/lib/sendmail
	ln -sf ../bin/msmtpq-ng-queue-mta $(1)/usr/sbin/mailq
	ln -sf ../bin/msmtpq-ng-queue-mta $(1)/usr/sbin/postqueue
	ln -sf ../bin/msmtpq-ng-queue-mta $(1)/usr/sbin/postsuper
endef

define Package/msmtpq-ng-mta-smtpd/install
	$(INSTALL_DIR) $(1)/etc/xinetd.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/msmtpq-ng-mta/sendmail-bs.xinetd $(1)/etc/xinetd.d/msmtpq-ng-mta-smtpd
endef


$(eval $(call BuildPackage,msmtpq-ng))
$(eval $(call BuildPackage,msmtpq-ng-mta))
$(eval $(call BuildPackage,msmtpq-ng-mta-smtpd))
