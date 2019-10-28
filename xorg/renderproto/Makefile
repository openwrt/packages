# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=renderproto
PKG_VERSION:=0.11.1
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://www.x.org/releases/individual/proto/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=06735a5b92b20759204e4751ecd6064a2ad8a6246bb65b3078b862a00def2537

PKG_BUILD_PARALLEL:=1

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/renderproto
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=
  TITLE:=X11 Render extension wire protocol
  URL:=http://xorg.freedesktop.org/
endef

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

CONFIGURE_ARGS += \
  --prefix=/usr

define Build/InstallDev
	$(INSTALL_DIR) \
	  $(1)/usr/include \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/include/* \
	  $(1)/usr/include/

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/pkgconfig \
	  $(1)/usr/lib/
endef

define Package/renderproto/install
endef

$(eval $(call BuildPackage,renderproto))
