#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libgee
PKG_VERSION:=0.18.0
PKG_RELEASE:=2

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>

PKG_LICENSE:=LGPL-2.1 
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/libgee/0.18/
PKG_MD5SUM:=29ea6125e653d7e60b49a9a9544abc96

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_BUILD_DEPENDS:=vala/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/libgee
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+glib2
  TITLE:=libgee
  URL:=https://wiki.gnome.org/Libgee
endef

define Package/libgee/decription
  Libgee is an utility library providing GObject-based interfaces and classes
endef

CONFIGURE_ARGS += \
	--disable-doc

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/gee-0.8/ \
		$(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/*.so* \
		$(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc \
		$(1)/usr/lib/pkgconfig/
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/share/vala-`$(STAGING_DIR_HOSTPKG)/bin/valac --api-version`/vapi/
	$(INSTALL_DATA) \
                $(PKG_INSTALL_DIR)/usr/share/vala/vapi/* \
                $(STAGING_DIR_HOSTPKG)/share/vala-`$(STAGING_DIR_HOSTPKG)/bin/valac --api-version`/vapi
endef

define Package/libgee/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/*.so* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,libgee))
