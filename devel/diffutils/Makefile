#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=diffutils
PKG_VERSION:=3.3
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNU/diffutils
PKG_MD5SUM:=99180208ec2a82ce71f55b0d7389f1b3
PKG_MAINTAINER:=Roger D <rogerdammit@gmail.com>
PKG_LICENSE:=GPL-3.0

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/diffutils/Default
  SECTION:=devel
  CATEGORY:=Development
  DEPENDS:=+USE_GLIBC:librt
  TITLE:=diffutils
  URL:=http://www.gnu.org/software/diffutils/
endef

define Package/diffutils/description/Default
  The Diffutils package contains programs that show the differences between
  files or directories.
endef

CONFIGURE_VARS += \
	ac_cv_func_mempcpy=n
TARGET_CFLAGS += --std=gnu99

define GenTool
  define Package/diffutils-$(1)
  $(call Package/diffutils/Default)
    TITLE+= ($1)
  endef

  define Package/diffutils-$(1)/description
  $(call Package/diffutils/description/Default)
  This package contains the $1 tool
  endef

  define Package/diffutils-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(1) $$(1)/usr/bin/
  endef

  $$(eval $$(call BuildPackage,diffutils-$(1)))
endef

$(foreach x,sdiff diff3 diff cmp,$(eval $(call GenTool,$(x))))
