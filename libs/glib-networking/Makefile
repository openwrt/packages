include $(TOPDIR)/rules.mk

PKG_NAME:=glib-networking
PKG_VERSION:=2.80.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/$(PKG_NAME)/$(basename $(PKG_VERSION))
PKG_HASH:=b80e2874157cd55071f1b6710fa0b911d5ac5de106a9ee2a4c9c7bee61782f8e

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:gnome:glib-networking

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk
include $(INCLUDE_DIR)/nls.mk

MESON_ARGS += \
	-Dgnutls=enabled \
	-Dopenssl=enabled \
	-Denvironment_proxy=enabled \
	-Dlibproxy=disabled \
	-Dgnome_proxy=disabled \
	-Dinstalled_tests=false \
	-Ddebug_logs=false

define Package/libgio-gnutls
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+glib2 +libgnutls
  TITLE:=GLib2 GIO GNUTLS module
  URL:=http://www.gnome.org/
endef

define Package/libgio-gnutls/description
  GNUTLS backend for GLib2 GIO.
endef

define Package/libgio-openssl
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+glib2 +libopenssl
  TITLE:=GLib2 GIO OpenSSL module
  URL:=http://www.gnome.org/
endef

define Package/libgio-openssl/description
  OpenSSL backend for GLib2 GIO.
endef

define Package/libgio-environmentproxy
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+glib2
  TITLE:=GLib2 GIO environmentproxy module
  URL:=http://www.gnome.org/
endef

define Package/libgio-environmentproxy/description
  Proxy environment variables module GLib2 GIO.
endef

define Package/libgio-gnutls/install
	$(INSTALL_DIR) $(1)/usr/lib/gio/modules
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/gio/modules/libgiognutls.so \
		$(1)/usr/lib/gio/modules
endef

define Package/libgio-openssl/install
	$(INSTALL_DIR) $(1)/usr/lib/gio/modules
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/gio/modules/libgioopenssl.so \
		$(1)/usr/lib/gio/modules
endef

define Package/libgio-environmentproxy/install
	$(INSTALL_DIR) $(1)/usr/lib/gio/modules
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/gio/modules/libgioenvironmentproxy.so \
		$(1)/usr/lib/gio/modules
endef

$(eval $(call BuildPackage,libgio-gnutls))
$(eval $(call BuildPackage,libgio-openssl))
$(eval $(call BuildPackage,libgio-environmentproxy))
