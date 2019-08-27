#
# Copyright (C) 2009 David Cooper <dave@kupesoft.com>
# Copyright (C) 2016-2019 Daniel Dickinson <cshored@thecshore.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=msmtp-scripts
PKG_VERSION:=1.2.4
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://launchpad.net/$(PKG_NAME)/1.2/$(PKG_VERSION)/+download
PKG_HASH:=fc85ab8ed1348be584adfc1feb89f51daed7404e9e8643652ff31d2af00f1cf5
PKG_MAINTAINER:=Daniel F. Dickinson <cshored@thecshore.com>

PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/msmtp-scripts/Default
  SECTION:=mail
  CATEGORY:=Mail
  TITLE:=Forwarding only SMTP with queuing
  URL:=https://msmtp-scripts.thecshore.com
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
  ALTERNATIVES:=\
    400:/usr/sbin/sendmail:/usr/sbin/msmtpq-ng-mta \
    400:/usr/lib/sendmail:/usr/sbin/msmtpq-ng-mta \
    400:/usr/sbin/mailq:/usr/sbin/msmtpq-ng-queue-mta \
    400:/usr/sbin/postqueue:/usr/sbin/msmtpq-ng-queue-mta \
    400:/usr/sbin/postsuper:/usr/sbin/msmtpq-ng-queue-mta
endef

define Package/msmtpq-ng-mta/conffiles
/etc/msmtpq-ng-mta.rc
endef

define Package/msmtpq-ng-mta/description
 $(call Package/msmtp-scripts/Default/description)
 This package provides sendmail, mailq, postfix,
 and postsuper symlinks to wrappers that configure
 msmtpq-ng for use as the system mail transport
 agent via the sendmail command.

**NB**: In order for msmtpq-ng-mta aka sendmail to
send mail for non-root users (not just queue it
after failing), the user must have permissions to
access /etc/msmtprc -- package msmtp sets msmtprc
to rw only by root by default as a security measure
(it _can_ contain information like passwords with
which to send mail through your email server).

There are a couple of choices.  One is to leave
the default permissions (in which cases the mail
will queue and fail to send until the mailq -q
runner which runs in a root crontab sends the mail).
Another is to give any non-root daemon users (or
any other users) group access (i.e. create a
group for all the users who should be able to
send mail, add the users to it, and give the
group read-only permissions on the msmtrpc).
A final option (which is only resonable if you
have no secrets in msmtprc because you are
sending unauthenticated mail to a server that
accepts mail directly for the intended user --
usually that means a self-hosted system mail
server, rather than trying to send mail to
public servers (which don't typically accept
mail from normal user IP addresses, even if
you ISP doesn't block the traffic) is to
make msmtprc world readable.

The first option is probably the best choice
for most users, as it just means a 15
minute delay in the mail getting off the
system, and doesn't involve special permissions
for non-root daemons or users.
endef

define Package/msmtpq-ng-mta-smtpd
$(call Package/msmtp-scripts/Default)
  DEPENDS+= +msmtpq-ng-mta +xinetd
  TITLE+= (localhost SMTPd)
  USERID:=msmtp=482:msmtp=482
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

define Package/msmtpq-ng-mta-smtpd/conffiles
/etc/xinetd.d/ms-mta-smtpd
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
	$(CP) $(PKG_BUILD_DIR)/src/usr/bin/msmtpq-ng $(1)/usr/bin/
	$(SED) "s,nc -vz,printf \"HEAD / HTTP/1.1\\\\r\\\\nHost: \$$$${EMAIL_CONN_TEST_SITE}\\\\r\\\\n\\\\r\\\\n\"|nc," $(1)/usr/bin/msmtpq-ng
	$(CP) $(PKG_BUILD_DIR)/src/usr/bin/msmtpq-ng-queue $(1)/usr/bin/
endef

define Package/msmtpq-ng-mta/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/sbin $(1)/usr/lib $(1)/etc/init.d
	$(INSTALL_DATA) ./files/msmtpq-ng-mta.rc $(1)/etc/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/usr/sbin/msmtpq-ng-mta $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/usr/sbin//msmtpq-ng-queue-mta $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/crontabs
	$(INSTALL_BIN) ./files/msmtpq-ng-mta.init $(1)/etc/init.d/msmtpq-ng-mta
endef

define Package/msmtpq-ng-mta-smtpd/install
	$(INSTALL_DIR) $(1)/etc/xinetd.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/etc/xinetd.d/ms-mta-smtpd $(1)/etc/xinetd.d/ms-mta-smtpd
endef


$(eval $(call BuildPackage,msmtpq-ng))
$(eval $(call BuildPackage,msmtpq-ng-mta))
$(eval $(call BuildPackage,msmtpq-ng-mta-smtpd))
