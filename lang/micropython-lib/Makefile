#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=micropython-lib
PKG_VERSION=1.8.6-$(PKG_SOURCE_VERSION)
PKG_RELEASE:=1

PKG_MAINTAINER:=Roger D <rogerdammit@gmail.com>
PKG_LICENSE:=MIT, PSFL
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/micropython/micropython-lib.git
PKG_SOURCE_VERSION:=f81e979c56dddb771ad36ec381b7f2c6cd12111f

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.gz
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
	-C $(PKG_BUILD_DIR) \
	PREFIX=$(PKG_BUILD_DIR)/_install_tmp \
	install

define Package/micropython-lib/install
	$(INSTALL_DIR) $(1)/usr/lib/micropython
	$(CP) $(PKG_BUILD_DIR)/_install_tmp/* $(1)/usr/lib/micropython
endef

$(eval $(call BuildPackage,micropython-lib))

