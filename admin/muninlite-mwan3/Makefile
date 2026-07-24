#
# Copyright (C) 2025 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=muninlite-mwan3
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Jonas Lochmann <openwrt@jonaslochmann.de>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/muninlite-mwan3
  SECTION:=admin
  CATEGORY:=Administration
  DEPENDS:=+muninlite +ucode-mod-ubus
  TITLE:=Munin plugin for mwan3
endef

define Package/muninlite-mwan3/description
 Munin plugin for mwan3.
 Munin is a monitoring system for Unix networks.
endef

define Build/Compile
	# nothing to do
endef

define Package/muninlite-mwan3/install
	$(INSTALL_DIR) $(1)/usr/share/munin/plugins
	$(INSTALL_BIN) ./files/mwan3.ucode \
		$(1)/usr/share/munin/plugins/mwan3

	$(INSTALL_DIR) $(1)/etc/munin/plugins/

	# we use an absolute target path here
	# that does not exist at the host
	$(LN) /usr/share/munin/plugins/mwan3 \
		$(1)/etc/munin/plugins/mwan3
endef

$(eval $(call BuildPackage,muninlite-mwan3))
