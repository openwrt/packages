#
# Copyright (C) 2007-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=flent-tools
PKG_VERSION:=0.14.0-git
PKG_LICENSE:=GPLv3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_REV).tar.gz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/tohojo/flent
PKG_REV:=272714a45c1cd25216ea772d40f35820323bfd79
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)

include $(INCLUDE_DIR)/package.mk

define Package/flent-tools
  SECTION:=util
  CATEGORY:=Utilities
  TITLE:=Helper programs for the Flent test tool
  URL:=https://flent.org
  MAINTAINER:=Toke Høiland-Jørgensen <toke@toke.dk>
  DEPENDS+=+librt
endef

define Package/flent-tc_iterate/description
	This builds the C helper programs for gathering data for
	the Flent network testing tool. These tools are needed for
	gathering data when a Bash shell is not available (and also
	perform better than the shell equivalents).
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/misc \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -std=gnu99"
endef

define Package/flent-tools/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/misc/tc_iterate $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/misc/wifistats_iterate $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,flent-tools))
