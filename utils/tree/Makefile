#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tree
PKG_VERSION:=2.1.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Old-Man-Programmer/$(PKG_NAME)/tar.gz/$(PKG_VERSION)?
PKG_HASH:=3ffe2c8bb21194b088ad1e723f0cf340dd434453c5ff9af6a38e0d47e0c2723b

PKG_MAINTAINER:=Banglang Huang <banglang.huang@foxmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/tree
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=List contents of directories in a tree-like format
  DEPENDS:=+libc +libgcc
endef

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)"

define Package/tree/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tree $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,tree))
