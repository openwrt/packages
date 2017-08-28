#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=memtester
PKG_VERSION:=4.3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://pyropus.ca/software/memtester/old-versions/
PKG_HASH:=f9dfe2fd737c38fad6535bbab327da9a21f7ce4ea6f18c7b3339adef6bf5fd88
PKG_MAINTAINER:=GuoWei Lim <limguowei@gmail.com>

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/memtester
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Userspace utility for testing the memory subsystem for faults
  URL:=https://packages.debian.org/source/sid/memtester
endef

define Package/memtester/description
 A userspace utility for testing the memory subsystem for faults.
endef

define Build/Configure
	$(SED) 's|cc -O2|$(TARGET_CC) $(TARGET_CFLAGS)|' $(PKG_BUILD_DIR)/conf-cc
	$(SED) 's|cc|$(TARGET_CC)|' $(PKG_BUILD_DIR)/conf-ld
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) all
endef

define Package/memtester/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/memtester $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,memtester))
