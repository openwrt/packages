#
# Copyright (C) 2009-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bonnie++
PKG_VERSION:=1.97.3
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=https://www.coker.com.au/bonnie++/
PKG_HASH:=e27b386ae0dc054fa7b530aab6bdead7aea6337a864d1f982bc9ebacb320746e

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
TARGET_LDFLAGS +=-nodefaultlibs
endif

TARGET_CXXFLAGS +=-fno-rtti

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		TARGET_CXX="$(TARGET_CXX)" \
		TARGET_LINK="$(TARGET_CXX)" \
		MORECFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CXXFLAGS)" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all
endef

define Package/bonniexx/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/bonnie++ $(1)/usr/bin/
	$(CP) $(PKG_BUILD_DIR)/bon_csv2html $(1)/usr/bin/
endef

$(eval $(call BuildPackage,bonniexx))
