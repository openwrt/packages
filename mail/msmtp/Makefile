#
# Copyright (C) 2009 David Cooper <dave@kupesoft.com>
# Copyright (C) 2009-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=msmtp
PKG_VERSION:=1.6.2
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@SF/msmtp
PKG_MD5SUM:=3baca93c7e5f1aa9d36a2e5b38739ab9

PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/msmtp/Default
  SECTION:=mail
  CATEGORY:=Mail
  TITLE:=Simple sendmail SMTP forwarding
  URL:=http://msmtp.sourceforge.net/
endef

define Package/msmtp/Default/description
 msmtp is an SMTP client. In the default mode, it transmits a mail to
 an SMTP server (for example at a free mail provider) which does the
 delivery. To use this program with your mail user agent (MUA), create
 a configuration file with your mail account(s) and tell your MUA to
 call msmtp instead of /usr/sbin/sendmail.
endef

define Package/msmtp
$(call Package/msmtp/Default)
  DEPENDS+= +libopenssl
  TITLE+= (with SSL support)
  VARIANT:=ssl
endef

define Package/msmtp/conffiles
/etc/msmtprc
endef

define Package/msmtp/description
$(call Package/msmtp/Default/description)
 This package is built with SSL support.
endef

define Package/msmtp-nossl
$(call Package/msmtp/Default)
  TITLE+= (without SSL support)
  VARIANT:=nossl
endef

define Package/msmtp-nossl/description
$(call Package/msmtp/Default/description)
 This package is built without SSL support.
endef

define Package/msmtp-mta
$(call Package/msmtp/Default)
  TITLE+= (with SSL support)
  DEPENDS+= +msmtp
  VARIANT:=ssl
endef

define Package/msmtp-mta/description
$(call Package/msmtp/Default/description)
 This package add a link from sendmail to msmtp
 and is built with SSL support.
endef

define Package/msmtp-nossl-mta
$(call Package/msmtp/Default)
  TITLE+= (without SSL support)
  DEPENDS+= +msmtp-nossl
  VARIANT:=nossl
endef

define Package/msmtp-nossl-mta/description
$(call Package/msmtp/Default/description)
 This package add a link from sendmail to msmtp
 and is built without SSL support.
endef

define Package/msmtp-queue
$(call Package/msmtp/Default)
  DEPENDS+= +bash +msmtp
  TITLE+= (queue scripts)
  VARIANT:=ssl
endef

define Package/msmtp-queue/description
$(call Package/msmtp/Default/description)
 This package contains the msmtp queue scripts.
 uses msmtp with SSL.
endef

define Package/msmtp-queue-nossl
$(call Package/msmtp/Default)
  DEPENDS+= +bash +msmtp-nossl
  TITLE+= (queue scripts)
  VARIANT:=nossl
endef

define Package/msmtp-queue-nossl/description
$(call Package/msmtp/Default/description)
 This package contains the msmtp queue scripts and
 uses msmtp without SSL.
endef

define Package/msmtp-queue-mta
$(call Package/msmtp/Default)
  DEPENDS+= +bash +msmtp-queue
  TITLE+= (queue scripts)
  VARIANT:=ssl
endef

define Package/msmtp-queue-mta/description
$(call Package/msmtp/Default/description)
 This package add a link from sendmail to msmtpq
 and is built with SSL support.
endef

define Package/msmtp-queue-nossl-mta
$(call Package/msmtp/Default)
  DEPENDS+= +bash +msmtp-queue-nossl
  TITLE+= (queue scripts)
  VARIANT:=nossl
endef

define Package/msmtp-queue-nossl-mta/description
$(call Package/msmtp/Default/description)
 This package add a link from sendmail to msmtpq
 and is built without SSL support.
endef

CONFIGURE_ARGS += \
	--disable-rpath \
	--without-libintl-prefix \
	--without-libgsasl \
	--without-libidn \
	--without-libsecret \
	--without-macosx-keyring \

ifneq ($(CONFIG_USE_UCLIBC),)
  CONFIGURE_ARGS += --disable-gai-idn
endif

MAKE_FLAGS :=

ifeq ($(BUILD_VARIANT),ssl)
	CONFIGURE_ARGS += \
		--with-tls=openssl
endif

ifeq ($(BUILD_VARIANT),nossl)
	CONFIGURE_ARGS += \
		--with-tls=no
endif

define Package/msmtp/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/doc/msmtprc-system.example \
		$(1)/etc/msmtprc
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/msmtp $(1)/usr/bin/
endef

define Package/msmtp-mta/install
	true
endef

define Package/msmtp-mta/postinst
	[ -e $${IPKG_INSTROOT}/usr/sbin/sendmail ] || {
		mkdir -p $${IPKG_INSTROOT}/usr/sbin
		ln -sf ../bin/msmtp $${IPKG_INSTROOT}/usr/sbin/sendmail
	}
endef

define Package/msmtp-mta/prerm
	[ "../bin/msmtp" = "$(readlink -qs $${IPKG_INSTROOT}/usr/sbin/sendmail)" ] && {
		rm -f $${IPKG_INSTROOT}/usr/sbin/sendmail
	}
endef

define Package/msmtp-queue/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/msmtpq/msmtp{q,-queue} $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/msmtpqueue/msmtp-{en,list,run}queue.sh $(1)/usr/bin/
endef

define Package/msmtp-queue-mta/install
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/usr/sbin
	$(INSTALL_BIN) ./files/msmtp-queue-mta.init $(1)/etc/init.d/msmtp-queue-mta
endef

define Package/msmtp-queue-mta/postinst
	sed -i -e 's,^Q=.*,Q=/var/spool/msmtp,' $${IPKG_INSTROOT}/usr/bin/msmtpq
	sed -i -e 's,^LOG=.*,LOG=/var/log/msmtp,' $${IPKG_INSTROOT}/usr/bin/msmtpq
	sed -i -e 's/^EMAIL_CONN_TEST=n/EMAIL_CONN_TEST=p/' $${IPKG_INSTROOT}/usr/bin/msmtpq
	[ -e $${IPKG_INSTROOT}/usr/sbin/sendmail ] || {
		mkdir -p $${IPKG_INSTROOT}/usr/sbin
		ln -sf ../bin/msmtpq $${IPKG_INSTROOT}/usr/sbin/sendmail
	}
endef

Package/msmtp-nossl/conffiles = $(Package/msmtp/conffiles)
Package/msmtp-nossl/install = $(Package/msmtp/install)
Package/msmtp-queue-nossl/install = $(Package/msmtp-queue/install)
Package/msmtp-nossl-mta/install = $(Package/msmtp-mta/install)
Package/msmtp-nossl-mta/postinst = $(Package/msmtp-mta/postinst)
Package/msmtp-nossl-mta/postrm = $(Package/msmtp-mta/postrm)
Package/msmtp-queue-nossl-mta/install = $(Package/msmtp-queue-mta/install)
Package/msmtp-queue-nossl-mta/postinst = $(Package/msmtp-queue-mta/postinst)
Package/msmtp-queue-nossl-mta/postrm = $(Package/msmtp-queue-mta/postrm)

$(eval $(call BuildPackage,msmtp))
$(eval $(call BuildPackage,msmtp-nossl))
$(eval $(call BuildPackage,msmtp-queue))
$(eval $(call BuildPackage,msmtp-mta))
$(eval $(call BuildPackage,msmtp-nossl-mta))
$(eval $(call BuildPackage,msmtp-queue-mta))
$(eval $(call BuildPackage,msmtp-queue-nossl-mta))
