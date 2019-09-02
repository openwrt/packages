#
# Copyright (C) 2007-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gkrellmd
PKG_VERSION:=2.3.10
PKG_RELEASE:=2

PKG_SOURCE:=gkrellm-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://gkrellm.srcbox.net/releases
PKG_HASH:=8b9ec8baadcd5830c6aff04ba86dc9ed317a15c1c3787440bd1e680fb2fcd766
PKG_MAINTAINER:=Peter Denison <openwrt@marshadder.org>
PKG_LICENSE:=GPL-2.0-or-later

PKG_BUILD_DIR:=$(BUILD_DIR)/gkrellm-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/gkrellmd
  SECTION:=admin
  CATEGORY:=Administration
  DEPENDS:=+glib2
  TITLE:=The GNU Krell Monitors Server
  URL:=http://gkrellm.net/
endef

define Package/gkrellmd/description
	Gkrellmd listens for connections from gkrellm clients. When
	a gkrellm client connects to a gkrellmd server all builtin
	monitors collect their data from the server.
endef

define Package/gkrellmd/conffiles
/etc/$(PKG_NAME).conf
endef

define Build/Compile
	CFLAGS="$(TARGET_CFLAGS) $(EXTRA_CPPFLAGS)" \
	LDFLAGS="$(EXTRA_LDFLAGS) " \
	$(MAKE) -C $(PKG_BUILD_DIR)/server \
		CC="$(TARGET_CC)" \
		glib2="yes" \
		without-libsensors="yes" \
		GLIB2_LIB="$(TARGET_LDFLAGS) -lglib-2.0 -lgmodule-2.0" \
		GLIB2_INCLUDE="-I$(STAGING_DIR)/usr/include/glib-2.0 -I$(STAGING_DIR)/usr/lib/glib-2.0/include"
endef

define Package/gkrellmd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/server/$(PKG_NAME) $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/server/$(PKG_NAME).conf $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/$(PKG_NAME).init $(1)/etc/init.d/$(PKG_NAME)
endef

$(eval $(call BuildPackage,gkrellmd))
