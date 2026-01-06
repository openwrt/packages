#
# Copyright (C) 2017-2025 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tree
PKG_VERSION:=2.2.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Old-Man-Programmer/$(PKG_NAME)/tar.gz/$(PKG_VERSION)?
PKG_HASH:=5caddcbca805131ff590b126d3218019882e4ca10bc9eb490bba51c05b9b3b75

PKG_MAINTAINER:=Banglang Huang <banglang.huang@foxmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/tree
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=List contents of directories in a tree-like format
  URL:=https://oldmanprogrammer.net/source.php?dir=projects/tree
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
