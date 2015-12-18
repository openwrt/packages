# 
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=findutils
PKG_VERSION:=4.4.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/$(PKG_NAME)
PKG_MD5SUM:=351cc4adb07d54877fa15f75fb77d39f
PKG_MAINTAINER:=Daniel Dickinson <openwrt@daniel.thecshore.com>
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_FORTIFY_SOURCE:=0
PKG_FIXUP:=autoreconf
PKG_REMOVE_FILES:=configure

include $(INCLUDE_DIR)/package.mk

define Package/findutils/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=GNU findutils
  URL:=http://www.gnu.org/software/findutils/
endef

define Package/findutils
$(call Package/findutils/Default)
  MENU:=1
endef

define Package/findutils-common
  $(call Package/findutils/Default)
  TITLE:=Common files for GNU findutils
  DEPENDS:=findutils
endef

define Package/findutils-find
  $(call Package/findutils/Default)
  TITLE:=Full version of find (GNU)
  DEPENDS:=findutils +findutils-common
endef

define Package/findutils-xargs
  $(call Package/findutils/Default)
  TITLE:=Full version of xargs (GNU)
  DEPENDS:=findutils +findutils-common
endef

define Package/findutils-locate
  $(call Package/findutils/Default)
  TITLE:=GNU locate and updatedb
  DEPENDS:=findutils +findutils-common
endef

define Package/findutils/description/Default
 Full versions of GNU findutils . Normally, you would not use this
 package, since the usually the functionality in BusyBox is sufficient
 and smaller, the exception being for power command line users
 who might miss having some functionality not included in the BusyBox
 builds.
endef

define Package/findutils/description
$(call Package/findutils/description/Default)
endef

define Package/findutils-common/description
$(call Package/findutils/description/Default)
  This package contains common files for findutils.
endef

define Package/findutils-find/description
$(call Package/findutils/description/Default)
  This package contains find.
endef

define Package/findutils-xargs/description
$(call Package/findutils/description/Default)
  This package contains xargs.
endef

define Package/findutils-locate/description
$(call Package/findutils/description/Default)
  This package contains locate (and required updatedb)
endef

define Build/Configure
	rm -rf $(PKG_BUILD_DIR)/gnulib
	ln -s $(PKG_BUILD_DIR)/gl $(PKG_BUILD_DIR)/gnulib
	$(call Build/Configure/Default,$(1),$(2),$(3),$(4))
endef

define Package/findutils/install
	true
endef

define Package/findutils-common/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/charset.alias $(1)/usr/lib/
endef

define Package/findutils-find/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/find $(1)/usr/bin/
endef

define Package/findutils-xargs/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/xargs $(1)/usr/bin/
endef

define Package/findutils-locate/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/locate $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/updatedb $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/bigram $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/code $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/frcode $(1)/usr/lib/
endef

$(eval $(call BuildPackage,findutils))
$(eval $(call BuildPackage,findutils-common))
$(eval $(call BuildPackage,findutils-find))
$(eval $(call BuildPackage,findutils-xargs))
$(eval $(call BuildPackage,findutils-locate))
