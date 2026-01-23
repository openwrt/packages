#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=taskwarrior
PKG_VERSION:=2.6.2
PKG_RELEASE:=1

PKG_SOURCE:=task-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.taskwarrior.org/download
PKG_HASH:=b1d3a7f000cd0fd60640670064e0e001613c9e1cb2242b9b3a9066c78862cfec
PKG_BUILD_DIR:=$(BUILD_DIR)/task-$(PKG_VERSION)

PKG_MAINTAINER:=
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/taskwarrior
  TITLE:=taskwarrior
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libstdcpp +libuuid +libgnutls
  URL:=https://taskwarrior.org/
endef

define Package/taskwarrior/description
 taskwarrior is a command-line todo list manager
endef

define Package/taskwarrior/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/task $(1)/usr/bin/
endef

$(eval $(call BuildPackage,taskwarrior))
