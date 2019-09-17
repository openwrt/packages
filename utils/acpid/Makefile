#
# Copyright (C) 2012-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=acpid
PKG_VERSION:=2.0.30
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@SF/acpid2
PKG_HASH:=28b77b62d3f64ebd1c2a3d16bccc6d4333b4e24a86aeacebec255fad223cf4cb
PKG_MAINTAINER:=Thomas Heil <heil@terminal-consulting.de>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:tedfelix:acpid

include $(INCLUDE_DIR)/package.mk

define Package/acpid
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=The ACPI Daemon (acpid) With Netlink Support
  URL:=https://sourceforge.net/projects/acpid2/
  DEPENDS:=+kmod-input-evdev
endef

define Package/acpid/description
  The ACPI Daemon (acpid) With Netlink Support
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_CC)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		all
endef

define Package/acpid/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/acpid $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/acpi_listen $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/acpi/events
	$(INSTALL_CONF) ./files/default $(1)/etc/acpi/events/default
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_CONF) ./files/acpid.init $(1)/etc/init.d/acpid
	chmod 0750 $(1)/etc/init.d/acpid
	$(INSTALL_DIR) $(1)/etc/hotplug.d/input/
	$(INSTALL_CONF) ./files/acpid.hotplug $(1)/etc/hotplug.d/input/
endef

define Package/acpid/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	echo "waiting for input devices to come up"
	/etc/init.d/acpid enable
	sleep 5
	/etc/init.d/acpid start
	echo "please try the power button"
	exit 0
}
endef

$(eval $(call BuildPackage,acpid))
