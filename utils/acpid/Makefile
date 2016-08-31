#
# Copyright (C) 2012-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=acpid
PKG_VERSION:=2.0.27
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@SF/acpid2 
PKG_MD5SUM:=e41bdf628e122edb4342fca432ea7db9
PKG_MAINTAINER:=Thomas Heil <heil@terminal-consulting.de>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/acpid
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=The ACPI Daemon (acpid) With Netlink Support
  URL:=http://tedfelix.com/linux/acpid-netlink.html
  DEPENDS:=@(TARGET_x86||TARGET_x86_64) +kmod-input-evdev 
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
