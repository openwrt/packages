#
# Copyright (C) 2007-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gkrellmd
PKG_VERSION:=2.3.10
PKG_RELEASE:=1

PKG_SOURCE:=gkrellm-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://gkrellm.srcbox.net/releases
PKG_MD5SUM:=ccc0b6af434542a2374e34a135ae68da

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
	Gkrellmd Listens for connections from gkrellm clients. When
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
		without-libsensors="yes"
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
