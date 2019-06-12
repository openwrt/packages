#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=diffutils
PKG_VERSION:=3.6
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNU/diffutils
PKG_HASH:=d621e8bdd4b573918c8145f7ae61817d1be9deb4c8d2328a65cea8e11d783bd6
PKG_MAINTAINER:=Roger D <rogerdammit@gmail.com>
PKG_LICENSE:=GPL-3.0

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/diffutils
  SECTION:=devel
  CATEGORY:=Development
  DEPENDS:=+USE_GLIBC:librt
  TITLE:=diffutils
  URL:=http://www.gnu.org/software/diffutils/
  ALTERNATIVES:=\
    200:/usr/bin/cmp:/usr/bin/gnu-cmp \
    200:/usr/bin/diff:/usr/bin/gnu-diff \

endef

define Package/diffutils/description
  The Diffutils package contains programs that show the differences between
  files or directories.
endef

CONFIGURE_VARS += \
	ac_cv_func_mempcpy=n
TARGET_CFLAGS += --std=gnu99

define Package/diffutils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/{sdiff,diff3} $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/diff $(1)/usr/bin/gnu-diff
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/cmp $(1)/usr/bin/gnu-cmp
endef

$(eval $(call BuildPackage,diffutils))
