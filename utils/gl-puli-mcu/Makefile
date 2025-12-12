include $(TOPDIR)/rules.mk

PKG_NAME:=gl-puli-mcu
PKG_VERSION:=2
PKG_RELEASE:=1

PKG_MAINTAINER:=Nuno Goncalves <nunojpg@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later

PKG_CONFIG_DEPENDS:= \
  CONFIG_GL_PULI_MCU_XE300 \
  CONFIG_GL_PULI_MCU_XE3000

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/gl-puli-mcu/config
  source "$(SOURCE)/Config.in"
endef

define Package/gl-puli-mcu
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=GL.iNet power monitoring support
  DEPENDS:=+CONFIG_GL_PULI_MCU_XE300:kmod-usb-serial-ch341 +libubus +libubox
  MENU:=1
endef

ifeq ($(CONFIG_GL_PULI_MCU_XE300),y)
  TARGET_CFLAGS+=-DGL_TARGET=1
endif
ifeq ($(CONFIG_GL_PULI_MCU_XE3000),y)
  TARGET_CFLAGS+=-DGL_TARGET=2
endif

define Package/gl-puli-mcu/description
  Interfaces with GL.iNet Puli family power monitoring MCU over
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
