# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=fribidi
PKG_VERSION:=1.0.5
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/fribidi/fribidi/releases/download/v$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=6a64f2a687f5c4f203a46fa659f43dd43d1f8b845df8d723107e8a7e6158e4ce

#PKG_BUILD_DEPENDS:=
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
#PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/fribidi
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libexpat  \
	    +libfreetype +libxft +fontconfig
  TITLE:=Free Implementation of the Unicode Bidirectional Algorithm
  URL:=https://github.com/fribidi/fribidi
endef

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

CONFIGURE_ARGS += \
  --prefix=/usr \
  --disable-static \
  --disable-docs \
  --with-glib=no

define Build/InstallDev
	$(INSTALL_DIR) \
	  $(1)/usr/include \
	  $(1)/usr/lib \

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/include/* \
	  $(1)/usr/include/

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/{pkgconfig,*.so*} \
	  $(1)/usr/lib/
endef

define Package/fribidi/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/*.so* \
	  $(1)/usr/lib/
endef

$(eval $(call BuildPackage,fribidi))
