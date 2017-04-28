#
# Copyright (C) 2006-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libtins
PKG_VERSION:=3.5
PKG_RELEASE:=1

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/mfontanini/libtins/archive/
PKG_MD5SUM:=be029088c9fc8dc979022410b49a8e61

PKG_MAINTAINER:=Ben Smith <le.ben.smith@gmail.com>

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_LICENSE:=BSD-2-Clause

include $(INCLUDE_DIR)/package.mk

define Package/libtins
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libtins is a C++ network packet sniffing and crafting library
  URL:=http://libtins.github.io/
  MENU:=1
  DEPENDS:=+libpcap +libstdcpp
endef

define Package/libtins/description
libtins is a high-level, multiplatform C++ network packet sniffing and crafting library.
endef

define Build/Configure
	mkdir -p $(PKG_BUILD_DIR)/build
	cd $(PKG_BUILD_DIR)/build && cmake ../ -DCMAKE_FIND_ROOT_PATH=$(STAGING_DIR) \
	-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
	-DCMAKE_C_COMPILER=$(TARGET_CC) \
	-DCMAKE_CXX_COMPILER=$(TARGET_CXX) \
	-DLIBTINS_ENABLE_WPA2=0 \
	-DLIBTINS_ENABLE_CXX11=1 \
	-DCROSS_COMPILING=1 \
	-DCMAKE_INSTALL_PREFIX=$(PKG_INSTALL_DIR)
endef

define Build/Compile
	cd $(PKG_BUILD_DIR)/build && make
endef

define Build/Install
	cd $(PKG_BUILD_DIR)/build && make install
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/include/tins $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libtins.so* $(1)/usr/lib/
endef

define Package/libtins/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libtins.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libtins))
