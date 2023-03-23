#
# Copyright (C) 2010-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=foolsm
PKG_VERSION:=1.0.21
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://lsm.foobar.fi/download
PKG_HASH:=527d9c363aa62b9fc511b42c5a06f774a8767c4b5330db4d959c10b46b0dede7

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0-only

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=gc-sections lto

include $(INCLUDE_DIR)/package.mk

define Package/foolsm
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+msmtp
  TITLE:=A link state monitor
  URL:=http://lsm.foobar.fi/
endef

define Package/foolsm/description
  foolsm is a link state monitor for carrying out actions when a link
  transistions from the up to down state or vice versa.
endef

define Package/foolsm/conffiles
/etc/foolsm/foolsm.conf
endef

MAKE_FLAGS += \
	PREFIX="$(CONFIGURE_PREFIX)"

TARGET_LDFLAGS += -Wl,--as-needed

define Package/foolsm/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/foolsm $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/foolsm/script.d
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DATA) ./files/connections.conf $(1)/etc/foolsm/connections.conf
	$(INSTALL_DATA) ./files/foolsm.conf $(1)/etc/foolsm/foolsm.conf
	$(INSTALL_BIN) ./files/foolsm_script $(1)/etc/foolsm/script
	$(INSTALL_BIN) ./files/foolsm.init $(1)/etc/init.d/foolsm
endef

define Package/foolsm/conffiles
/etc/foolsm/connections.conf
/etc/foolsm/foolsm.conf
endef

$(eval $(call BuildPackage,foolsm))
