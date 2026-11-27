# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=orbi-bt-setup
PKG_VERSION:=0.3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Leo-ATP/openwrt-orbi-ble-service/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=fc47f493dd61086d67447facacbcbad723ab5d270e2306b6c29ccae5d9f6838e
PKG_BUILD_DIR:=$(BUILD_DIR)/openwrt-orbi-ble-service-$(PKG_VERSION)

PKG_MAINTAINER:=Zhixuan WU <cogito.wu@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/orbi-bt-setup
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Netgear Orbi RBR50/RBS50 v1 Bluetooth setup
  URL:=https://github.com/Leo-ATP/openwrt-orbi-ble-service
  DEPENDS:=@TARGET_ipq40xx +kmod-hci-uart +bluez-utils +bluez-daemon
endef

define Package/orbi-bt-setup/description
  Initializes the built-in CSR Bluetooth controller on Netgear Orbi RBR50
  and RBS50 v1. It discovers the board UART, applies the volatile 26 MHz CSR
  setting, then hands the controller to the standard BlueZ daemon.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		STRIP="$(TARGET_CROSS)strip" \
		CPPFLAGS="$(TARGET_CPPFLAGS) -I$(PKG_BUILD_DIR)/include -D_GNU_SOURCE" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		all
endef

define Package/orbi-bt-setup/preinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
umask 077
[ ! -L /var/run/orbi-bt-setup.skip-package-start ] || exit 1
: > /var/run/orbi-bt-setup.skip-package-start
endef

define Package/orbi-bt-setup/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/orbi-bt-setup $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/orbi-bt-setup.init \
		$(1)/etc/init.d/orbi-bt-setup
endef

$(eval $(call BuildPackage,orbi-bt-setup))
