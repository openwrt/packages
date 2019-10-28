# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=xf86-input-keyboard
PKG_VERSION:=1.9.0
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://www.x.org/releases/individual/driver/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=f7c900f21752683402992b288d5a2826de7a6c0c0abac2aadd7e8a409e170388

PKG_BUILD_DEPENDS:=util-macros xorgproto
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/xf86-input-keyboard
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libxi +xorg-server +libxkbfile +libxrandr
  TITLE:=X.org keyboard input driver
  URL:=https://www.x.org
endef

#LDFLAGS:="$LDFLAGS -Wl,-z,lazy"
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed,-z,lazy

CONFIGURE_ARGS += \
  --prefix=/usr

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

define Package/xf86-input-keyboard/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib/xorg/modules/input

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/xorg/modules/input/*.so* \
	  $(1)/usr/lib/xorg/modules/input/
endef

$(eval $(call BuildPackage,xf86-input-keyboard))
