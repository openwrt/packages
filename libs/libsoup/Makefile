#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libsoup
PKG_VERSION:=2.74.3
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/libsoup/$(basename $(PKG_VERSION))
PKG_HASH:=e4b77c41cfc4c8c5a035fcdc320c7bc6cfb75ef7c5a034153df1413fa1d92f13

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:gnome:libsoup

PKG_BUILD_DEPENDS:=glib2/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

define Package/libsoup
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libsoup
  URL:=https://wiki.gnome.org/Projects/libsoup
  DEPENDS:=+glib2 +libxml2 +libgnutls +libsqlite3 +libpsl $(ICONV_DEPENDS) $(INTL_DEPENDS)
endef

MESON_ARGS += \
	-Dgssapi=disabled \
	-Dntlm=disabled \
	-Dbrotli=disabled \
	-Dtls_check=false \
	-Dgnome=false \
	-Dintrospection=disabled \
	-Dvapi=disabled \
	-Dgtk_doc=false \
	-Dtests=false \
	-Dinstalled_tests=false \
	-Dsysprof=disabled

define package/libsoup/decription
Libsoup is an HTTP library implementation in C
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/{lib/pkgconfig,include/libsoup-2.4/libsoup}

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libsoup-2.4.so* \
		$(1)/usr/lib/

	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* \
		$(1)/usr/lib/pkgconfig/

	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/include/libsoup-2.4/libsoup/*.h \
		$(1)/usr/include/libsoup-2.4/libsoup/
endef

define Package/libsoup/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libsoup-2.4.so* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,libsoup))
