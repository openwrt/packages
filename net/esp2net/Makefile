include $(TOPDIR)/rules.mk

PKG_NAME:=esp2net
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0-only
PKG_MAINTAINER:=Nuno Gonçalves <nunojpg@gmail.com>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/nunojpg/esp2net.git
PKG_SOURCE_DATE:=2023-06-20
PKG_SOURCE_VERSION:=be514c7a50bd8f3aac146ba267856d66cad1abd9
PKG_MIRROR_HASH:=941b3460ea5b7108a075bebb850cc568f79006e7f85a7831577bd18b2ebd90c9

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/esp2net
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Espressif ESP chip network monitor and flash proxy
	DEPENDS:=+libstdcpp
endef

define Package/esp2net/description
	Allows to flash a Espressif chip connected to this device.
	The functionality is identical to "esp_rfc2217_server.py" but without Python.
	Typically you want also to install one or more USB serial drivers:
	 * kmod-usb-serial-cp210x
	 * kmod-usb-serial-ftdi
	 * kmod-usb-serial-ch341
	 * kmod-usb-acm
endef

define Package/esp2net/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/esp2net $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/esp2net.init $(1)/etc/init.d/esp2net
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/esp2net.config $(1)/etc/config/esp2net
endef

define Package/esp2net/conffiles
/etc/config/esp2net
endef

$(eval $(call BuildPackage,esp2net))
