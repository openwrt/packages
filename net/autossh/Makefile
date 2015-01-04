#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=autossh
PKG_VERSION:=1.4d
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://www.harding.motd.ca/autossh/
PKG_MD5SUM:=89c09b50aa2d57814f808d727e937d0f

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Autossh client
  URL:=http://www.harding.motd.ca/autossh/
  SUBMENU:=SSH
endef

define Build/Compile
	$(call Build/Compile/Default, -f Makefile \
		CFLAGS="$(TARGET_CFLAGS) -Wall -D\"SSH_PATH=\\\"\$$$$(SSH)\\\"\" -D\"VER=\\\"\$$$$(VER)\\\"\"" \
		all \
	)
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/autossh $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/autossh.init $(1)/etc/init.d/autossh
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/autossh.config $(1)/etc/config/autossh
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./files/autossh.hotplug $(1)/etc/hotplug.d/iface/20-autossh
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/autossh
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
