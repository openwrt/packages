#
# Copyright (C) 2017 Steven Hessing
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libtins
PKG_RELEASE:=1

PKG_MAINTAINER:= Steven Hessing <steven.hessing@gmail.com>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/mfontanini/libtins.git
PKG_SOURCE_VERSION:=v3.5
PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.xz
PKG_MIRROR_HASH:=47cd7d659ffa75dcfc2172ef54151fd36dc87de9e0f04bb066f6b076a7df7b57

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
PKG_BUILD_PARALLEL:=1

CMAKE_INSTALL:=1
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
CMAKE_OPTIONS += -D_RUN_RESULT_VAR=FORCE
CMAKE_OPTIONS += -DLIBTINS_ENABLE_WPA2=0
CMAKE_OPTIONS += -DLIBTINS_ENABLE_CXX11=1

define Package/libtins
	SECTION:=net
	CATEGORY:=Libraries
	TITLE:=libtins 
	URL:=http://libtins.github.io/
	DEPENDS:=+libstdcpp +libpcap 
endef

define Package/libtins/description
libtins is a high-level, multiplatform C++ network packet sniffing and crafting library.
endef

define Package/libtins/install
    $(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libtins.so.3.5 $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libtins))
