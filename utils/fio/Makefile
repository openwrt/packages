#
# Copyright (C) 2018 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fio
PKG_VERSION:=3.13
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://brick.kernel.dk/snaps
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=a21d1e50c18eecbd5ee6f7c3c0a8c8605bbe31b91e07c387b2144b02ea3fb235

PKG_MAINTAINER:=Rosen Penev <rosenp@gmail.com>
PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/fio
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Disc
  DEPENDS:=+libaio +zlib
  TITLE:=I/O testing and benchmarking tool
  URL:=https://github.com/axboe/fio
endef

define Package/fio/description
  Fio is an I/O testing tool that will spawn a number of threads or
  processes doing a particular type of I/O action as specified by
  the user. Fio can be driven by a 'job file' describing the I/O
  load one wants to simulate.
endef

TARGET_CFLAGS := $(filter-out -O%,$(TARGET_CFLAGS))
TARGET_LDFLAGS += -Wl,--gc-sections

CONFIGURE_ARGS = \
	--disable-numa \
	--disable-rdma \
	--disable-rados \
	--disable-http \
	--disable-rbd \
	--disable-gfapi \
	--disable-lex \
	--disable-pmem \
	--disable-native \
	--cc="$(TARGET_CC)" \
	--extra-cflags="$(TARGET_CFLAGS)"

define Package/fio/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/fio $(1)/usr/bin/
endef

$(eval $(call BuildPackage,fio))
