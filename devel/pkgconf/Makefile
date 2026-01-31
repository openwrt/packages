#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pkgconf
PKG_VERSION:=1.8.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://distfiles.ariadne.space/pkgconf
PKG_HASH:=ef9c7e61822b7cb8356e6e9e1dca58d9556f3200d78acab35e4347e9d4c2bbaf

PKG_MAINTAINER:=Rosen Penev <rosenp@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:pkgconf:pkgconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/libpkgconf
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libpkgconf
  URL:=https://github.com/pkgconf/pkgconf
endef

define Package/pkgconf
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=pkgconf
  URL:=https://github.com/pkgconf/pkgconf
  DEPENDS:=+libpkgconf
endef

define Package/libpkgconf/description
  libpkgconf is a library which provides access to most of pkgconf’s
  functionality, to allow other tooling such as compilers and IDEs to
  discover and use frameworks configured by pkgconf. It features a stable
  library ABI and API designed for building bindings and other tools.
endef

define Package/pkgconf/description
  pkgconf is a program which helps to configure compiler and linker flags
  for development frameworks. It is similar to pkg-config from
  freedesktop.org, providing additional functionality while also
  maintaining compatibility.
endef

MESON_ARGS += \
	-Dtests=false

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/libpkgconf
	$(CP) $(PKG_INSTALL_DIR)/usr/include/pkgconf/libpkgconf/*.h $(1)/usr/include/libpkgconf
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpkgconf.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/share/aclocal/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/aclocal/pkg.m4 \
	  $(1)/usr/share/aclocal/
endef

define Package/libpkgconf/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpkgconf.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/share/aclocal/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/aclocal/pkg.m4 \
	  $(1)/usr/share/aclocal/
endef

define Package/pkgconf/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/pkgconf $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libpkgconf))
$(eval $(call BuildPackage,pkgconf))
