#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libsoup3
PKG_VERSION:=3.2.2
PKG_RELEASE:=1

PKG_SOURCE:=libsoup-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/libsoup/3.2
PKG_HASH:=83673c685b910fb7d39f1f28eee5afbefb71c05798fc350ac3bf1b885e1efaa1
PKG_BUILD_DIR:=$(BUILD_DIR)/libsoup-$(PKG_VERSION)

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:gnome:libsoup

PKG_BUILD_DEPENDS:=glib2/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

define Package/libsoup3
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libsoup3
  URL:=https://wiki.gnome.org/Projects/libsoup
  DEPENDS:=+glib2 +libxml2 +libgnutls +libsqlite3 +libpsl +libnghttp2
endef

MESON_ARGS += \
	-Dgssapi=disabled \
	-Dntlm=disabled \
	-Dbrotli=disabled \
	-Dtls_check=false \
	-Dintrospection=disabled \
	-Dvapi=disabled \
	-Dtests=false \
	-Dinstalled_tests=false \
	-Dsysprof=disabled

define package/libsoup3/decription
Libsoup is an HTTP library implementation in C
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/{lib/pkgconfig,include/libsoup-3.0/libsoup}

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libsoup-3.0.so* \
		$(1)/usr/lib/

	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* \
		$(1)/usr/lib/pkgconfig/

	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/include/libsoup-3.0/libsoup/*.h \
		$(1)/usr/include/libsoup-3.0/libsoup/
endef

define Package/libsoup3/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libsoup-3.0.* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,libsoup3))
