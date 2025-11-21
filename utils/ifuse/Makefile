#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ifuse
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/libimobiledevice/ifuse.git
PKG_SOURCE_DATE:=2024-12-02
PKG_SOURCE_VERSION:=bbf2838a474c287e28ed6d348ee252ddaeb9aab0
PKG_MIRROR_HASH:=b9bfd08c62cbb1dc8e36c1d8713be03149d87dbd6adc8aef952b7209c9c97a24

PKG_MAINTAINER:=Rosen Penev <rosenp@gmail.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:libimobiledevice:ifuse

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/ifuse
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=libimobiledevice
  TITLE:=Fuse filesystem access to iOS devices
  URL:=https://www.libimobiledevice.org/
  DEPENDS:=+fuse3-utils +libimobiledevice
endef

define Package/ifuse/description
  A fuse filesystem implementation to access the contents of iOS devices.
  This project allows mounting various directories of an iOS device locally
  using the FUSE file system interface.
  - Media: Mount media directory of an iOS device locally
  - Apps: Mount sandbox container or document directory of an app
  - Jailbreak: Mount root filesystem on jailbroken devices (requires AFC2 service)
  - Browse: Allows to retrieve a list of installed file-sharing enabled apps
endef

CONFIGURE_ARGS += \
	PACKAGE_VERSION=$(PKG_VERSION)

define Package/ifuse/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ifuse $(1)/usr/bin/
endef

$(eval $(call BuildPackage,ifuse))
