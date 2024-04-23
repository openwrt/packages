#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ideviceinstaller
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/libimobiledevice/ideviceinstaller.git
PKG_SOURCE_DATE:=2024-01-15
PKG_SOURCE_VERSION:=22872c3571b8d2646a9fbb74ec1d7e186941053d
PKG_MIRROR_HASH:=479d8694f36cf6aaa86dd4738d6fca29681b86957e516c317a3a58628f914fda

PKG_MAINTAINER:=Rosen Penev <rosenp@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:libimobiledevice:ideviceinstaller

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/ideviceinstaller
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=libimobiledevice
  TITLE:=Manage apps and app archives on iOS devices
  URL:=https://www.libimobiledevice.org/
  DEPENDS:=+libimobiledevice +libzip
endef

define Package/ideviceinstaller/description
  A command-line application to manage apps and app archives on iOS devices.
  Allows interacting with the app installation service of an iOS device.
  - Status: Install, upgrade, uninstall, and enumerate apps
  - Browse: Allows to retrieve a list of installed apps with filter options
  - Install: Supports app package, carrier bundle and developer .app directory
  - Format: Allows command output in plist, XML, or JSON format
  - Compatibility: Supports latest device firmware releases
endef

CONFIGURE_ARGS += \
	PACKAGE_VERSION=$(PKG_VERSION)

define Package/ideviceinstaller/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ideviceinstaller $(1)/usr/bin/
endef

$(eval $(call BuildPackage,ideviceinstaller))
