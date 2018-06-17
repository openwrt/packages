include $(TOPDIR)/rules.mk

PKG_NAME:=pkgconf
PKG_VERSION:=1.5.1
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://distfiles.dereferenced.org/pkgconf
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_HASH:=d6877d721f84b59f137da48b237f16e68b598f5afc4f2a04d0a5c9e7e2bf5462
PKG_MAINTAINER:=Rosen Penev <rosenp@gmail.com>
PKG_LICENSE:=GPL-2+

PKG_FIXUP:=autoreconf libtool
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/libpkgconf
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libpkgconf
  URL=http://pkgconf.org/
endef

define Package/pkgconf
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=pkgconf
  DEPENDS:=+libpkgconf
  URL:=http://pkgconf.org/
endef

define Package/pkgconf/description
  pkgconf is a helper tool used when compiling applications and libraries.
  It helps you insert the correct compiler options on the command line so an
  application can use gcc -o test test.cpkg-config --libs --cflags glib-2.0
  for instance, rather than hard-coding values on where to find glib (or
  other libraries).
endef

define Package/libpkgconf/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libpkgconf* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libpkgconf.pc $(1)/usr/lib/pkgconfig
endef

define Package/pkgconf/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/pkgconf $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/share/aclocal/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/pkg.m4 $(1)/usr/share/aclocal/
endef

$(eval $(call BuildPackage,libpkgconf))
$(eval $(call BuildPackage,pkgconf))
