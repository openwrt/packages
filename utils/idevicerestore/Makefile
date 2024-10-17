#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=idevicerestore
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/libimobiledevice/idevicerestore.git
PKG_SOURCE_DATE:=2024-09-28
PKG_SOURCE_VERSION:=511261e12d23d80cc3c08290022380b8d3411f9c
PKG_MIRROR_HASH:=ccdc4c7711173771be16521c90343a625f849b14fb15fa03d4fc44917905695d

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
