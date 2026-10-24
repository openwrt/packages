# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=ble-service
PKG_VERSION:=0.1.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Leo-ATP/openwrt-orbi-ble-service.git
PKG_SOURCE_VERSION:=11778dbc07536a8c99cf4ecd3563e0bb39e8a3f7
PKG_MIRROR_HASH:=b45dc16eb25ccfbe21e7aa5227644977be5ce1318b484a7af9a7790bd740c6e2

PKG_MAINTAINER:=Zhixuan WU <cogito.wu@gmail.com>
PKG_LICENSE:=GPL-2.0-only BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE LICENSE.godbus

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/Leo-ATP/openwrt-orbi-ble-service
GO_PKG_BUILD_PKG:=$(GO_PKG)
GO_PKG_LDFLAGS_X:=main.version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/ble-service
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Experimental Orbi RBR50/RBS50 v1 BLE central service
  URL:=https://github.com/Leo-ATP/openwrt-orbi-ble-service
  DEPENDS:=$(GO_ARCH_DEPENDS) @TARGET_ipq40xx +rpcd +dbus +bluez-daemon +bluez-utils +kmod-hci-uart
endef

define Package/ble-service/description
  Six-method rpcd BLE central service using BlueZ and the standard BCSP
  hci_uart transport. This experimental backend is limited to the built-in
  CSR8811 on the Netgear Orbi RBR50/RBS50 v1 with its UART enabled in the
  device tree. It requires exclusive Bluetooth ownership and does not
  replace a running bluetoothd. No pairing, trust or application GATT writes.
endef

# rpcd enumerates exec plugins only when it is reloaded.
define Package/ble-service/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || /etc/init.d/rpcd reload
endef

define Package/ble-service/postrm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || /etc/init.d/rpcd reload
endef

define Package/ble-service/install
	$(INSTALL_DIR) $(1)/usr/libexec/rpcd
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/openwrt-orbi-ble-service \
		$(1)/usr/libexec/rpcd/ble
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ble.init $(1)/etc/init.d/ble
	$(INSTALL_DIR) $(1)/usr/share/ble-service
	$(INSTALL_DATA) ./files/bus.conf ./files/main.conf $(1)/usr/share/ble-service/
endef

$(eval $(call BuildPackage,ble-service))
