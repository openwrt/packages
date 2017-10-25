#
# Copyright (C) 2009 David Cooper <dave@kupesoft.com>
# Copyright (C) 2009-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=msmtp
PKG_VERSION:=1.6.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@SF/msmtp
PKG_HASH:=da15db1f62bd0201fce5310adb89c86188be91cd745b7cb3b62b81a501e7fb5e

PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/msmtp/Default
  SECTION:=mail
  CATEGORY:=Mail
  DEPENDS:=$(INTL_DEPENDS)
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
  DEPENDS+= +libopenssl +ca-bundle
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
  TITLE+= (as MTA)
  DEPENDS+=@(PACKAGE_msmtp||PACAKGE_msmtp-nossl)
endef

define Package/msmtp-mta/description
$(call Package/msmtp/Default/description)
 This package add a link from sendmail to msmtp
 and is built with SSL support.
endef

define Package/msmtp-queue
$(call Package/msmtp/Default)
  DEPENDS+= +bash @(PACKAGE_msmtp||PACKAGE_msmtp-nossl)
  TITLE+= (queue scripts)
endef

define Package/msmtp-queue/description
$(call Package/msmtp/Default/description)
 This package contains the msmtp queue scripts.
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
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/usr/lib
	ln -sf ../bin/msmtp $(1)/usr/sbin/sendmail
	ln -sf ../bin/msmtp $(1)/usr/lib/sendmail
endef

Package/msmtp-nossl/conffiles = $(Package/msmtp/conffiles)
Package/msmtp-nossl/install = $(Package/msmtp/install)

define Package/msmtp-queue/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/msmtpq/msmtp{q,-queue} $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/msmtpqueue/msmtp-{en,list,run}queue.sh $(1)/usr/bin/
endef

$(eval $(call BuildPackage,msmtp))
$(eval $(call BuildPackage,msmtp-nossl))
$(eval $(call BuildPackage,msmtp-queue))
$(eval $(call BuildPackage,msmtp-mta))
