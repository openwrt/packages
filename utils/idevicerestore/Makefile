#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=idevicerestore
PKG_SOURCE_DATE:=2020-04-20
PKG_SOURCE_VERSION:=d1cb6bfef6ac8fb08472ac5f1fac93895084371c
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/libimobiledevice/idevicerestore
PKG_MIRROR_HASH:=1f0afb92a1a32b7ac929408c1dd5356329866a2672075d0f55dde7d31dac6cc2

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
  DEPENDS:=+libirecovery +libzip +libcurl +usbmuxd
endef

define Package/idevicerestore/description
  The idevicerestore tool allows to restore firmware files to iOS devices.
  It is a full reimplementation of all granular steps which are performed
  during restore of a firmware to a device.
endef

TARGET_LDFLAGS += $(if $(CONFIG_USE_GLIBC),-lpthread)

define Package/idevicerestore/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/idevicerestore $(1)/usr/bin/
endef

$(eval $(call BuildPackage,idevicerestore))
