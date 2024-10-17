#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libtatsu
PKG_VERSION:=1.0.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/libimobiledevice/libtatsu/releases/download/$(PKG_VERSION)
PKG_HASH:=4f69452d23e50e0ffbe844110e6ab6a900d080e051fbda3b7d595f679dee9bc5

PKG_MAINTAINER:=Rosen Penev <rosenp@gmail.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libtatsu
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=libimobiledevice
  TITLE:=Handle communication with Apple's Tatsu Signing Server (TSS)
  URL:=https://www.libimobiledevice.org/
  DEPENDS:=+libcurl +libplist
endef

define Package/libtatsu/description
  libtatsu is part of the libimobiledevice project.
  The main purpose is to allow creating TSS request payloads,
  sending them to Apple's TSS server, and retrieving and processing the
  response. The code was originally part of idevicerestore and has been split
  out to its own library, while obviously idevicerestore will remain the main
  consumer.
endef

CONFIGURE_ARGS += \
	--disable-static \
	--without-cython

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libtatsu $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtatsu.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libtatsu-1.0.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libtatsu/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtatsu.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libtatsu))
