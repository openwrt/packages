#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=idevicerestore
PKG_SOURCE_DATE:=2020-02-17
PKG_SOURCE_VERSION:=513950377df9cb93747ac69dae4ab55dded3ac5c
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/libimobiledevice/idevicerestore
PKG_MIRROR_HASH:=3b2c25cb47d79c02b225b83d8732ea1ab5b20f0e15f7d716cb4a26e99be4f53e

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
