# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=xf86-input-evdev
PKG_VERSION:=2.10.6
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://www.x.org/releases/individual/driver/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=8726073e81861bc7b2321e76272cbdbd33c7e1a121535a9827977265b9033ec0

PKG_BUILD_DEPENDS:=util-macros xorgproto
PKG_BUILD_PARALLEL:=1

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/xf86-input-evdev
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libxi +xorg-server +libxrandr +libevdev +mtdev
  TITLE:=X.org evdev input driver
  URL:=https://www.x.org
endef

#LDFLAGS:="$LDFLAGS -Wl,-z,lazy"
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed,-z,lazy

#MAKE_FLAGS+= \
#    -Wno-nested-externs \
#    -Wno-int-conversion \
#    -Wno-implicit-function-declaration

CONFIGURE_ARGS += \
  --prefix=/usr \
  --disable-werror

#define Build/InstallDev
#	$(INSTALL_DIR) \
#	  $(1)/usr/include \
#	  $(1)/usr/lib
#
#	$(CP) \
#	  $(PKG_INSTALL_DIR)/usr/include/* \
#	  $(1)/usr/include/
#
#	$(CP) \
#	  $(PKG_INSTALL_DIR)/usr/lib/{pkgconfig,*.so*} \
#	  $(1)/usr/lib/
#endef

define Package/xf86-input-evdev/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib/xorg/modules/input \
	  $(1)/etc/X11 \

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/xorg/modules/input/*.so* \
	  $(1)/usr/lib/xorg/modules/input/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/share/X11/xorg.conf.d \
	  $(1)/etc/X11/
endef

$(eval $(call BuildPackage,xf86-input-evdev))
