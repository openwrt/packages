include $(TOPDIR)/rules.mk

PKG_NAME:=libulfius
PKG_VERSION:=2.7.10
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/babelouest/ulfius/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=616c5df99584071461a1285dd7155883f7d2b94abf0931038feeebd3da3a6def

PKG_MAINTAINER:=Toni Uhlig <matzeton@googlemail.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-$(BUILD_VARIANT)/ulfius-$(PKG_VERSION)
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libulfius/default
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Networking
  TITLE:=Web Framework to build REST APIs, Webservices or any HTTP endpoint in C language.
  URL:=https://github.com/babelouest/ulfius
endef

define Package/libulfius-nossl
$(call Package/libulfius/default)
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
  DEPENDS:=+libmicrohttpd +libcurl +liborcania
  PROVIDES:=libulfius
endef

define Package/libulfius-gnutls
$(call Package/libulfius/default)
  TITLE+= with SSL support
  VARIANT:=gnutls
  DEPENDS:=+libmicrohttpd +libcurl +liborcania +libgnutls +zlib
  PROVIDES:=libulfius
endef

CMAKE_OPTIONS += \
	-D_GNU_SOURCE=ON \
	-DDOWNLOAD_DEPENDENCIES=OFF \
	-DBUILD_WEBSOCKET=OFF \
	-DSEARCH_ORCANIA_U=ON \
	-DWITH_CURL=ON \
	-DWITH_JANSSON=OFF \
	-DWITH_STRSTR=ON \
	-DWITH_YDER=OFF \
	-DSEARCH_YDER=OFF \
	-DCMAKE_BUILD_TYPE=Release

ifeq ($(BUILD_VARIANT),gnutls)
	CMAKE_OPTIONS += -DWITH_GNUTLS=ON
else
	CMAKE_OPTIONS += -DWITH_GNUTLS=OFF
endif

define Package/libulfius/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libulfius.so* $(1)/usr/lib/
endef

Package/libulfius-nossl/install = $(Package/libulfius/install)
Package/libulfius-gnutls/install = $(Package/libulfius/install)

$(eval $(call BuildPackage,libulfius-gnutls))
$(eval $(call BuildPackage,libulfius-nossl))
