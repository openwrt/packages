#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=idevicerestore
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/libimobiledevice/idevicerestore.git
PKG_SOURCE_DATE:=2025-07-15
PKG_SOURCE_VERSION:=197c9619b39f978a3400d2bbb3684fd3a222b268
PKG_MIRROR_HASH:=7132a424a87c582fe02d12bbc21f5f937a96b8a3fede9bb6c67ddafdec56678f

PKG_MAINTAINER:=Rosen Penev <rosenp@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/idevicerestore
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=libimobiledevice
  TITLE:=Restore/upgrade firmware of iOS devices
  URL:=https://github.com/libimobiledevice/idevicerestore
  DEPENDS:=+libirecovery +libzip +libtatsu +usbmuxd
endef

define Package/idevicerestore/description
  The idevicerestore tool allows to restore firmware files to iOS devices.
  It is a full reimplementation of all granular steps which are performed
  during restore of a firmware to a device.
endef

CONFIGURE_ARGS += \
	PACKAGE_VERSION=$(PKG_VERSION)

TARGET_LDFLAGS += $(if $(CONFIG_USE_GLIBC),-lpthread)

define Package/idevicerestore/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/idevicerestore $(1)/usr/bin/
endef

$(eval $(call BuildPackage,idevicerestore))
