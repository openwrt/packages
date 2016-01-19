#
# Copyright (C) 2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# blogic@openwrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=build-essential
PKG_RELEASE:=1
PKG_VERSION:=1

include $(INCLUDE_DIR)/package.mk

define Package/build-essential
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=Build essentials
  DEPENDS=+gcc +make +binutils +patch +diffutils @NO_STRIP
  PKGARCH:=all
endef

define Build/Compile

endef

define Package/build-essential/install
    cp -r ./files/* $(1)
endef

$(eval $(call BuildPackage,build-essential))
