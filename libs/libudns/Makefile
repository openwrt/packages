#
# Copyright (C) 2012 ezbox project
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=udns
PKG_VERSION:=0.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.corpit.ru/mjt/udns
PKG_MD5SUM:=51e141b044b078d71ebb71f823959c1b

include $(INCLUDE_DIR)/package.mk

define Package/udns/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=http://www.corpit.ru/mjt/udns.html
  SUBMENU:=IP Addresses and Names
endef

define Package/udns-libs
  $(call Package/udns/Default)
  TITLE:=udns library, stub DNS resolver -  shared libraries 
endef

define Package/udns-libs/description
The DNS library, udns, implements thread-safe stub DNS resolver functionality, which may be used both traditional, syncronous way and asyncronously, with application-supplied event loop.
endef

define Package/udns-utils
  $(call Package/udns/Default)
  TITLE+= udns utils, stub DNS resolver (all)
endef

export BUILD_CC="$(TARGET_CC)"
export CC="$(TARGET_CC)"
export AR="$(TARGET_CROSS)ar"
export RANLIB="$(TARGET_CROSS)ranlib"

define Build/Configure
	(cd $(PKG_BUILD_DIR); \
		./configure \
		--enable-cross_compile \
		$(DISABLE_IPV6) \
	)
endef
define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) all
	$(MAKE) -C $(PKG_BUILD_DIR) shared
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/udns
	$(CP) $(PKG_BUILD_DIR)/udns.h $(1)/usr/include/udns
	$(CP) $(PKG_BUILD_DIR)/udns.h $(1)/usr/include

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib*.{a,so*} $(1)/usr/lib
endef

define Package/udns-libs/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib*.so* $(1)/usr/lib
endef

define Package/udns-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dnsget $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ex-rdns $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rblcheck $(1)/usr/bin/
endef

$(eval $(call BuildPackage,udns-libs))
$(eval $(call BuildPackage,udns-utils))
