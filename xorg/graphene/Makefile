# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=graphene
PKG_VERSION:=1.6.2
_PKG_VERSION:=1.6
PKG_RELEASE:=1

#PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=http://ftp.gnome.org/pub/GNOME/sources/$(PKG_NAME)/$(_PKG_VERSION)/
##141PKG_SOURCE_VERSION:=b9f909aad03d845155e3da3c1ab9236adb1b3a16
#PKG_SOURCE_VERSION:=729cd7f59471cd03e7d97908650acd2b2b0ba9ee
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_HASH:=8f7d1984c06aefe3b47a668c12ad9f3db0bcb2d09c55e6267b82a90f6b10d961

#HOST_BUILD_DEPENDS:=util-macros/host mkfontscale/host
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/graphene
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+glib2
  TITLE:=A thin layer of types for graphic libraries
  URL:=https://github.com/ebassi/graphene
endef

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

CONFIGURE_ARGS += \
  --prefix=/usr

define Build/InstallDev
	$(INSTALL_DIR) \
	  $(1)/usr/include \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/include \
	  $(1)/usr/

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/graphene-1.0/include/*.h \
	  $(1)/usr/include/graphene-1.0

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/{pkgconfig,*.so*} \
	  $(1)/usr/lib/
endef

define Package/graphene/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/*.so* \
	  $(1)/usr/lib/
endef

$(eval $(call BuildPackage,graphene))
