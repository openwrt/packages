#
# Copyright (C) 2021 Michal Hrusecky <michal@hrusecky.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=afuse
PKG_VERSION:=0.4.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Michal Hrusecky <michal@hrusecky.net>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/pcarrier/$(PKG_NAME)/archive/refs/tags/v$(PKG_VERSION).tar.gz?
PKG_HASH:=8c7950cdeb24cdff828cdd3807537ee12cab87b18ecef4496b7bdedb2b8bd0e9

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/afuse
  SECTION:=net
  CATEGORY:=Utilities
  SUBMENU:=Filesystem
  TITLE:=Automounting file system implemented in user-space using FUSE
  DEPENDS:=+libfuse +fuse-utils
  URL:=https://github.com/pcarrier/afuse
endef

define Package/afuse/description
  Automounting file system implemented in user-space using FUSE. It
  implements the most basic functionality that can be expected by an
  automounter; that is it manages a directory of virtual directories. If
  one of these virtual directories is accessed and is not already
  automounted, afuse will attempt to mount a filesystem onto that
  directory. If the mount succeeds the requested access proceeds as
  normal, otherwise it will fail with an error.
endef

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/fuse/

define Package/afuse/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/afuse $(1)/usr/bin/
endef

$(eval $(call BuildPackage,afuse))
