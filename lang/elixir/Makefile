#
# Copyright (C) 2020 Xiaobo Tian <peterwillcn@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=elixir
PKG_VERSION:=1.10.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/elixir-lang/elixir/archive/v$(PKG_VERSION)
PKG_HASH:=f3035fc5fdade35c3592a5fa7c8ee1aadb736f565c46b74b68ed7828b3ee1897

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Xiaobo Tian <peterwillcn@gmail.com>

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/elixir
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Elixir scripting language
  URL:=https://elixir-lang.org
  DEPENDS:=+erlang +erlang-compiler +erlang-runtime-tools +erlang-hipe
endef

define Package/elixir/description
  Elixir is a dynamic, functional language designed for building
  scalable and maintainable applications
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
	PREFIX="$(PKG_INSTALL_DIR)/usr" \
  install
endef

define Package/elixir/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/elixir/lib
	$(INSTALL_DIR) $(1)/usr/lib/elixir/bin

	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/elixir/lib/* $(1)/usr/lib/elixir/lib/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/elixir/bin/* $(1)/usr/lib/elixir/bin/
endef

$(eval $(call BuildPackage,elixir))
