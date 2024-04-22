#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libimobiledevice-glue
PKG_VERSION:=1.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/libimobiledevice/libimobiledevice-glue/releases/download/$(PKG_VERSION)
PKG_HASH:=ff9cbc240c9780edfa43914a057b86362054053721b65fb04f54a25023b92b62

PKG_MAINTAINER:=Rosen Penev <rosenp@gmail.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libimobiledevice-glue/Default
  TITLE:=Common code used by libimobiledevice.
  URL:=https://www.libimobiledevice.org/
  SUBMENU:=libimobiledevice
endef

define Package/libimobiledevice-glue/Default/description
  libimobiledevice-glue is a library with common code used by the
  libraries and tools around the libimobiledevice project.
endef

define Package/libimobiledevice-glue
  $(call Package/libimobiledevice-glue/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libplist
  LICENSE:=LGPL-2.1-or-later
  LICENSE_FILES:=COPYING
endef

define Package/libimobiledevice-glue/description
  $(call Package/libimobiledevice-glue/Default/description)
endef

CONFIGURE_ARGS += \
	--disable-static \
	--without-cython

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libimobiledevice-glue $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libimobiledevice-glue-1.0.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libimobiledevice-glue-1.0.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libimobiledevice-glue/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libimobiledevice-glue-1.0.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libimobiledevice-glue))
