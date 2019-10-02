#
# Copyright (C) 2019 EWSI
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mrmctl
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE:=macremapper-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ewsi/macremapper/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=f054201dd805ce005b89606a507b58a5717d383a4339c69dfdc02f0202935437
PKG_BUILD_DIR:=$(BUILD_DIR)/macremapper-$(PKG_VERSION)

PKG_MAINTAINER:=Carey Sonsino <careys@edgewaterwireless.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=userland/COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/mrmctl
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=mrmctl utility (macremapper kernel module)
  URL:=https://www.edgewaterwireless.com
  DEPENDS:= +kmod-macremapper
endef

define Package/mrmctl/description
  Command-line utility to manually manipulate the macremapper kernel module
endef

MAKE_PATH:=userland
CONFIGURE_PATH:=userland
CONFIGURE_ARGS += \
	--enable-shared

TARGET_CFLAGS += -std=c89 -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
endef

define Package/mrmctl/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(1)/bin/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,mrmctl))
