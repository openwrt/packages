#
# Copyright (C) 2007-2011 OpenWrt.org
# Copyright (C) 2015 Daniel Dickinson <openwrt@daniel.thecshore.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/uclibc++.mk

PKG_NAME:=nullmailer
PKG_VERSION:=1.13
PKG_RELEASE:=4
PKG_MAINTAINER:=Daniel Dickinson <openwrt@daniel.thecshore.com>
PKG_LICENSE:=GPL-2.0+

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://untroubled.org/nullmailer/
PKG_MD5SUM:=aaeb8746fbc082917b26d0827ccc9270
PKG_USERID:=nullmailer=5236:nullmailer=5236

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += $(TARGET_CPPFLAGS)

CONFIGURE_ARGS += \
	--localstatedir=/var/spool

ifeq ($(BUILD_VARIANT),ssl)
CONFIGURE_ARGS+=--enable-tls
endif

define NullmailerPackageSet
  define Package/nullmailer$(if $(filter-out plain,$(1)),-$(1))
    SECTION:=mail
    CATEGORY:=Mail
    DEPENDS:=$(CXX_DEPENDS) $(if $(filter ssl,$(1)),+libgnutls)
    TITLE:=A minimal MTA for hosts which relay to a fixed set of smart relays $(1) variant
    URL:=http://untroubled.org/nullmailer/
    VARIANT:=$(1)
  endef

  define Package/nullmailer$(if $(filter-out plain,$(1)),-$(1))/description
   This is nullmailer, a sendmail/qmail/etc replacement MTA for hosts
   which relay to a fixed set of smart relays.  It is designed to be
   simple to configure, secure, and easily extendable.
  endef

  define Package/nullmailer$(if $(filter-out plain,$(1)),-$(1))/conffiles
  /etc/nullmailer
  /etc/config/nullmailer
  endef

  define Package/nullmailer$(if $(filter-out plain,$(1)),-$(1))/install
	$(INSTALL_DIR) $$(1)/etc/init.d $$(1)/usr/bin $$(1)/usr/sbin $$(1)/usr/lib/nullmailer $$(1)/etc/config $$(1)/sbin
	$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/bin/* $$(1)/usr/bin/
	$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/sbin/* $$(1)/usr/sbin/
	$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/lib/nullmailer/* $$(1)/usr/lib/nullmailer/
	$(INSTALL_BIN) ./files/nullmailer.init $$(1)/etc/init.d/nullmailer
	$(INSTALL_CONF) ./files/nullmailer.config $$(1)/etc/config/nullmailer
	ln -sf /var/etc/nullmailer $$(1)/etc/nullmailer
	ln -sf /usr/sbin/nullmailer-sendmail $$(1)/sbin/sendmail
	ln -sf /sbin/sendmail $$(1)/usr/lib/sendmail
  endef

   $$(eval $$(call BuildPackage,nullmailer$(if $(filter-out plain,$(1)),-$(1))))
endef
$(eval $(call NullmailerPackageSet,plain))
$(eval $(call NullmailerPackageSet,ssl))
