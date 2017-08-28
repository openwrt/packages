#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=taskwarrior
PKG_VERSION:=2.4.4
PKG_RELEASE:=1

PKG_LICENSE:=MIT

PKG_SOURCE:=task-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.taskwarrior.org/download/
PKG_HASH:=7ff406414e0be480f91981831507ac255297aab33d8246f98dbfd2b1b2df8e3b
PKG_MAINTAINER:=Luka Perkov <luka@openwrt.org>

PKG_BUILD_DIR:=$(BUILD_DIR)/task-$(PKG_VERSION)

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/taskwarrior
  TITLE:=taskwarrior
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libstdcpp +libuuid +libgnutls
  URL:=http://taskwarrior.org/
endef

TARGET_LDFLAGS += -ldl

define Package/taskwarrior/description
 taskwarrior is a command-line todo list manager
endef

define Package/taskwarrior/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/task $(1)/usr/bin/
endef

$(eval $(call BuildPackage,taskwarrior))
