#
# Copyright (C) 2016 Yousong Zhou <yszhou4tech@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dtc
PKG_VERSION:=1.4.2
PKG_RELEASE:=2
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.kernel.org/pub/software/utils/dtc
PKG_SOURCE_MD5SUM:=3d5814e31b2046ef51fca8fece998db0
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=GPL
PKG_INSTALL:=1
PKG_MAINTAINER:=Yousong Zhou <yszhou4tech@gmail.com>

include $(INCLUDE_DIR)/package.mk


define Package/dtc
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Device Tree Compiler
  URL:=http://devicetree.org/Device_Tree_Compiler
endef

define Package/dtc/description
  Device Tree Compiler for Flat Device Trees Device Tree Compiler, dtc, takes
  as input a device-tree in a given format and outputs a device-tree in another
  format for booting kernels on embedded systems.
endef

define Package/dtc/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/bin/dtc $(1)/usr/bin
endef


define Package/libfdt
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=a utility library for reading and manipulating dtb files
  URL:=http://devicetree.org/Device_Tree_Compiler
endef

define Package/libfdt/description
  This is a library containing functions for manipulating Flat Device Trees.
endef

define Package/libfdt/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libfdt*.so* $(1)/usr/lib
endef

TARGET_CFLAGS += \
	$(FPIC)

MAKE_FLAGS += \
	PREFIX= \
	CFLAGS="$(TARGET_CFLAGS)"

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/include/* $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/lib/* $(1)/usr/lib
endef

$(eval $(call BuildPackage,dtc))
$(eval $(call BuildPackage,libfdt))
