#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=totem-pl-parser
PKG_VERSION:=3.26.6
PKG_RELEASE:=1

PKG_SOURCE:=totem-pl-parser-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/totem-pl-parser/$(basename $(PKG_VERSION))
PKG_HASH:=c0df0f68d5cf9d7da43c81c7f13f11158358368f98c22d47722f3bd04bd3ac1c

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=LGPL-2-or-later
PKG_LICENSE_FILES:=COPYING.LIB

PKG_BUILD_DEPENDS:=glib2/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

define Package/totem-pl-parser
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+glib2 +libxml2 +shared-mime-info
  TITLE:=totem-pl-parser
  URL:=https://gitlab.gnome.org/GNOME/totem-pl-parser
endef

define Package/totem-pl-parser/decription
  totem-pl-parser is a simple GObject-based library to parse a host of playlist formats
endef

MESON_ARGS += -Dintrospection=false \
              -Denable-libarchive=no \
              -Denable-libgcrypt=no

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/totem-pl-parser/ \
		$(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/*.so* \
		$(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/totem-pl-parser/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/*.so* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,totem-pl-parser))
