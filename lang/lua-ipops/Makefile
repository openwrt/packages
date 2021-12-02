#
# Copyright (C) 2017-2019 Chen Minqiang <ptpt52@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-ipops
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

PKG_SOURCE_VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)
PKG_MAINTAINER:=Chen Minqiang <ptpt52@gmail.com>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/lua-ipops
  CATEGORY:=X
  SUBMENU:=Libs
  DEPENDS:=
  TITLE:=lua ipops lib
endef

define Package/lua-ipops/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DATA) ./src/ipops.lua $(1)/usr/lib/lua/ipops.lua
endef

define Build/Prepare
	true
endef

define Build/Compile
	true
endef

$(eval $(call BuildPackage,lua-ipops))
