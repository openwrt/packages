#
# Copyright (C) 2017 Steven Hessing
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libtins
PKG_VERSION:=4.0
PKG_RELEASE:=3

PKG_MAINTAINER:= Steven Hessing <steven.hessing@gmail.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/mfontanini/libtins/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=2a758d1bed51760bbd57fcaa00610534e0cc3a6d55d91983724e5f46739d66b8

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

CMAKE_INSTALL:=1
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
CMAKE_OPTIONS += -D_RUN_RESULT_VAR=FORCE
CMAKE_OPTIONS += -DLIBTINS_ENABLE_WPA2=0
CMAKE_OPTIONS += -DLIBTINS_ENABLE_CXX11=1

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/ $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/include/tins $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtins* $(1)/usr/lib/
endef

define Package/libtins
	SECTION:=net
	CATEGORY:=Libraries
	TITLE:=libtins
	URL:=https://libtins.github.io/
	DEPENDS:=+libstdcpp +libpcap
endef

define Package/libtins/description
libtins is a high-level, multiplatform C++ network packet sniffing and crafting library.
endef

define Package/libtins/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtins.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libtins))
