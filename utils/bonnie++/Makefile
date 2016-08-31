#
# Copyright (C) 2009-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bonnie++
PKG_VERSION:=1.97
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://www.coker.com.au/bonnie++/experimental/
PKG_MD5SUM:=d6cf9703242998b2ddc2d875b028b3c6
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=copyright.txt
PKG_MAINTAINER:=Florian Fainelli <florian@openwrt.org>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION).1

include $(INCLUDE_DIR)/package.mk

define Package/bonniexx
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libstdcpp +libpthread
  TITLE:=Bonnie++ - hard drive bottleneck testing program.
  URL:=http://www.coker.com.au/bonnie++/
endef

define Package/bonniexx/description
  Bonnie++ is a benchmark suite that is aimed at performing a number of simple
  tests of hard drive and file system performance.
endef

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
