# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=fluxbox
PKG_VERSION:=1.3.7
PKG_RELEASE:=1

PKG_SOURCE_URL:=@SF/fluxbox
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_HASH:=fc8c75fe94c54ed5a5dd3fd4a752109f8949d6df67a48e5b11a261403c382ec0

PKG_BUILD_DEPENDS:=xorgproto
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/fluxbox
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libx11 +libxinerama +libxpm +libxrandr +libxrender +libxrandr \
	    +libfreetype +libxft +libstdcpp +fontconfig +imlib2 +fribidi
  TITLE:=A lightweight and highly-configurable window manager
  URL:=http://www.fluxbox.org
endef

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

CONFIGURE_ARGS += \
  --prefix=/usr \
  --enable-imlib2

define Package/fluxbox/install
	$(INSTALL_DIR) \
	  $(1)/usr/bin \
	  $(1)/usr/share

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/bin/* \
	  $(1)/usr/bin/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/share \
	  $(1)/usr/
endef

$(eval $(call BuildPackage,fluxbox))
