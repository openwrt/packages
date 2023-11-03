#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=jq
PKG_VERSION:=1.6
PKG_RELEASE:=2
PKG_LICENSE:=BSD

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/stedolan/jq.git
PKG_SOURCE_DATE:=2018-11-02
PKG_SOURCE_VERSION:=2e01ff1fb69609540b2bdc4e62a60499f2b2fb8e
PKG_MIRROR_HASH:=ee52d2dce67dfbea633020d11a908d5818145a2bf87e5a0a17c0ff6885a428a7
PKG_MAINTAINER:=Marko Ratkaj <markoratkaj@gmail.com>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

ifdef CONFIG_USE_MIPS16
  TARGET_CFLAGS += -fno-ipa-sra
endif

TARGET_CFLAGS += -std=c99

CONFIGURE_ARGS+= \
	--disable-docs \
	--disable-valgrind \
	--without-oniguruma

define Package/jq
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Lightweight and flexible command-line JSON processor.
  URL:=https://stedolan.github.io/jq/
endef

define Package/jq/description
	Lightweight and flexible command-line JSON processor.
endef

define Package/jq/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,jq))
