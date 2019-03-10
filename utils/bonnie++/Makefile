#
# Copyright (C) 2009-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bonnie++
PKG_VERSION:=1.98
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=https://www.coker.com.au/bonnie++/
PKG_HASH:=6e0bcbc08b78856fd998dd7bcb352d4615a99c26c2dc83d5b8345b102bad0b04

PKG_MAINTAINER:=Florian Fainelli <florian@openwrt.org>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=copyright.txt

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/bonniexx
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=$(CXX_DEPENDS) +libpthread
  TITLE:=Bonnie++ - hard drive bottleneck testing program.
  URL:=https://www.coker.com.au/bonnie++/
endef

define Package/bonniexx/description
  Bonnie++ is a benchmark suite that is aimed at performing a number of simple
  tests of hard drive and file system performance.
endef

ifeq ($(CONFIG_USE_UCLIBCXX),y)
TARGET_LDFLAGS += -nodefaultlibs
endif

TARGET_CXXFLAGS += -fno-rtti -flto

define Package/bonniexx/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/bonnie++ $(1)/usr/bin/
	$(CP) $(PKG_BUILD_DIR)/bon_csv2html $(1)/usr/bin/
endef

$(eval $(call BuildPackage,bonniexx))
