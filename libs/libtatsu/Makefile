#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libtatsu
PKG_VERSION:=1.0.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/libimobiledevice/libtatsu/releases/download/$(PKG_VERSION)
PKG_HASH:=536fa228b14f156258e801a7f4d25a3a9dd91bb936bf6344e23171403c57e440

PKG_MAINTAINER:=Georgi Valkov <gvalkov@gmail.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libtatsu/Default
  TITLE:=Handle communication with Apple's Tatsu Signing Server (TSS)
  URL:=https://www.libimobiledevice.org/
  SUBMENU:=libimobiledevice
endef

define Package/libtatsu/Default/description
  libtatsu is part of the libimobiledevice project.
  The main purpose is to allow creating TSS request payloads,
  sending them to Apple's TSS server, and retrieving and processing the
  response. The code was originally part of idevicerestore and has been split
  out to its own library, while obviously idevicerestore will remain the main
  consumer.
endef

define Package/libtatsu
  $(call Package/libtatsu/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libcurl +libplist
  LICENSE:=LGPL-2.1-or-later
  LICENSE_FILES:=COPYING
endef

define Package/libtatsu/description
  $(call Package/libtatsu/Default/description)
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
