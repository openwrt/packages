include $(TOPDIR)/rules.mk

PKG_NAME:=bluld
PKG_VERSION:=1.1.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/ktgeek/$(PKG_NAME)/releases/download/v$(PKG_VERSION)
PKG_HASH:=382def82bb1486633b2dbf2f399b7b11ab854c4f79957066b7a31b556abd0158

PKG_MAINTAINER:=Keith T. Garner <kgarner@kgarner.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/kernel.mk

include $(INCLUDE_DIR)/cmake.mk

define Package/bluld
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Blinkstick User space LED Daemon
  DEPENDS:=+kmod-usb-hid +kmod-leds-uleds +libstdcpp +hidapi
endef

define Package/bluld/description
  A daemon to expose a Blinkstick to the Linux kernel LED class via /dev/uleds. (Kernel 4.10+ required.)
endef

define Package/bluld/conffiles
/etc/config/bluld
endef

define Package/bluld/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/bluld $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/bluld.conf $(1)/etc/config/bluld
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/bluld.init $(1)/etc/init.d/bluld
endef

$(eval $(call BuildPackage,bluld))
