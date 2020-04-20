#
# Copyright (C) 2009-2020 OpenWrt.org
#
# This is free software, licensed under the GPL License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=elixir
PKG_VERSION:=v1.10.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/elixir-lang/elixir/archive/$(PKG_VERSION)
PKG_HASH:=5adffcf4389aa82fcfbc84324ebbfa095fc657a0e15b2b055fc05184f96b2d50

PKG_MAINTAINER:=Xiaobo Tian <peterwillcn@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/elixir/Default
  SUBMENU:=Elixir
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Elixir scripting language
  URL:=http://elixir-lang.org
endef

define Package/elixir/Default/description
	Elixir is a dynamic, functional language designed for building
	scalable and maintainable applications
endef

define Package/elixir
$(call Package/elixir/Default)
  DEPENDS:=+erlang +erlang-compiler +erlang-runtime-tools +erlang-hipe
endef

define Package/elixir/description
$(call Package/elixir/Default/description)
 .
 This package contains the runtime implementation and a minimal set of
 modules.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		PREFIX="$(PKG_INSTALL_DIR)/usr" \
		compile
endef

define Package/elixir/install
	$(INSTALL_DIR) $(1)/usr/lib/elixir/bin
	$(INSTALL_DIR) $(1)/usr/lib/elixir/lib
	$(INSTALL_DIR) $(1)/usr/bin

	$(CP) $(PKG_INSTALL_DIR)/usr/lib/elixir/lib/* $(1)/usr/lib/elixir/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/elixir/bin/* $(1)/usr/lib/elixir/bin/
endef

$(eval $(call BuildPackage,elixir))
