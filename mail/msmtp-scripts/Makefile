#
# Copyright (C) 2009 David Cooper <dave@kupesoft.com>
# Copyright (C) 2016-2018 Daniel Dickinson <cshored@thecshore.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=msmtp-scripts
PKG_VERSION:=1.2-b-3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://launchpad.net/$(PKG_NAME)/$(firstword $(subst -, ,$(PKG_VERSION)))/$(PKG_VERSION)/+download
PKG_HASH:=b1d112df3ba8f42848102ba75d678a3ecef6dae6dd78b12a1357772313292639
PKG_MAINTAINER:=Daniel F. Dickinson <cshored@thecshore.com>

PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/msmtp-scripts/Default
  SECTION:=mail
  CATEGORY:=Mail
  TITLE:=Forwarding only SMTP with queuing
  URL:=https://launchpad.net/msmtp-scripts
endef

define Package/msmtp-scripts/Default/description
 msmtp-scripts are scripts wrappers around the msmtp SMTP client that
 add queueing, logging to syslog or file, and a subset of sendmail/postfix
 mailq/postsuper/postqueue commands implemented in a compatible fashion.
endef

define Package/msmtpq-ng
$(call Package/msmtp-scripts/Default)
  DEPENDS+= +msmtp
  TITLE+= (common)
endef

define Package/msmtpq-ng/conffiles
/etc/msmtpq-ng.rc
/etc/msmtpq-ng-msmtprc
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
  ALTERNATIVES:=\
    400:/usr/sbin/sendmail:/usr/bin/msmtpq-ng-mta \
    400:/usr/lib/sendmail:/usr/bin/msmtpq-ng-mta \
    400:/usr/sbin/mailq:/usr/bin/msmtpq-ng-queue-mta \
    400:/usr/sbin/postqueue:/usr/bin/msmtpq-ng-queue-mta \
    400:/usr/sbin/postsuper:/usr/bin/msmtpq-ng-queue-mta
endef

define Package/msmtp-queue-mta/conffiles
/etc/msmtpq-ng-mta.rc
/etc/msmtpq-ng-mta-msmtprc
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
  TITLE+= (localhost SMTPd)
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
	if ! grep -q msmtpq-ng-mta $${IPKG_INSTROOT}/etc/crontabs/root 2>/dev/null; then echo $$'\n'"*/60 * * * * /usr/bin/msmtpq-ng-mta -q" >>$${IPKG_INSTROOT}/etc/crontabs/root; fi
endef

define Build/Configure
	true
endef

define Build/Compile
	true
endef

define Package/msmtpq-ng/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) ./files/msmtpq-ng.rc $(1)/etc/msmtpq-ng.rc
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/msmtpq-ng/msmtpq-ng $(1)/usr/bin/
	$(CP) $(PKG_BUILD_DIR)/msmtpq-ng/msmtpq-ng-queue $(1)/usr/bin/
endef

define Package/msmtpq-ng-mta/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/sbin $(1)/usr/lib $(1)/etc/init.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/msmtpq-ng-mta/msmtpq-ng-mta.rc $(1)/etc/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/msmtpq-ng-mta/msmtpq-ng-mta $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/msmtpq-ng-mta/msmtpq-ng-queue-mta $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/crontabs
	$(INSTALL_BIN) ./files/msmtpq-ng-mta.init $(1)/etc/init.d/msmtpq-ng-mta
	ln -s /etc/msmtprc $(1)/etc/msmtpq-ng-mta-msmtprc
endef

define Package/msmtpq-ng-mta-smtpd/install
	$(INSTALL_DIR) $(1)/etc/xinetd.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/msmtpq-ng-mta/sendmail-bs.xinetd $(1)/etc/xinetd.d/msmtpq-ng-mta-smtpd
endef


$(eval $(call BuildPackage,msmtpq-ng))
$(eval $(call BuildPackage,msmtpq-ng-mta))
$(eval $(call BuildPackage,msmtpq-ng-mta-smtpd))
