#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=micropython-lib
PKG_VERSION=1.9-$(PKG_SOURCE_VERSION)
PKG_RELEASE:=1

PKG_MAINTAINER:=Roger D <rogerdammit@gmail.com>
PKG_LICENSE:=MIT, PSFL
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/micropython/micropython-lib.git
PKG_SOURCE_VERSION:=f5fe55aaef1a39d3d56f07040c0ff9f7e841fdf7

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.xz
PKG_MIRROR_HASH:=76565b5d44d47ccf61562f98dcf166d8103760eed7f3d84f5f7f31610140d780
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/micropython-lib
    SUBMENU:=Python
    SECTION:=lang
    CATEGORY:=Languages
    TITLE:=micropython-lib
    URL:=https://github.com/micropython/micropython-lib
    DEPENDS:=+micropython
endef

define Package/micropython-lib/description
    This package contains micropython-lib, a project to develop a non-monolothic
    standard library for Micro Python. Note that this is a work in progress and
    several libraries may be missing, incomplete or buggy.
endef

MAKE_FLAGS:=\
	PREFIX=$(PKG_BUILD_DIR)/_install_tmp/dist \
	install

define Package/micropython-lib/install
	$(INSTALL_DIR) $(1)/usr/lib/micropython
	$(CP) $(PKG_BUILD_DIR)/_install_tmp/dist/* $(1)/usr/lib/micropython
endef

$(eval $(call BuildPackage,micropython-lib))

