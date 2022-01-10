include $(TOPDIR)/rules.mk

PKG_NAME:=gl-puli-mcu
PKG_VERSION:=1
PKG_RELEASE:=$(AUTORELEASE)

PKG_MAINTAINER:=Nuno Goncalves <nunojpg@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/gl-puli-mcu
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=GL.iNet GL-XE300 (Puli) power monitoring support
  DEPENDS:=+kmod-usb-serial-ch341 +libubus +libubox
endef

define Package/gl-puli-mcu/description
  Interfaces with GL-XE300 (Puli) power monitoring MCU over
  a USB to UART adapter present on the device and provides
  battery SOC, temperature, charging state and cycle count at
  ubus battery/info.
endef

define Package/gl-puli-mcu/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/gl-puli-mcu $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,gl-puli-mcu))
