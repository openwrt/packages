#
# Copyright (C) 2019 Jerônimo Cordoni Pellegrini <j_p@aleph0.info>
#
# This file is free software, licensed under the GNU General Public License v3.
# For more information, pleae see https://www.gnu.org/licenses/gpl
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rlwrap
PKG_VERSION=0.43
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/rlwrap-$(PKG_VERSION)
PKG_SOURCE:=rlwrap-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/hanslub42/rlwrap/releases/download/v$(PKG_VERSION)/
PKG_HASH:=8e86d0b7882d9b8a73d229897a90edc207b1ae7fa0899dca8ee01c31a93feb2f

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILE:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/rlwrap
SECTION:=utils
CATEGORY:=Utilities
TITLE:=rlwrap
DEPENDS:= +libreadline
URL:=https://github.com/hanslub42/rlwrap
MAINTAINER:=Jeronimo Pellegrini <j_p@aleph0.info>
endef

define Package/rlwrap/description
  rlwrap is a 'readline wrapper', a small utility that uses the GNU
  readline library to allow the editing of keyboard input for any
  command.
endef

define Package/rlwrap/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/src/rlwrap $(1)/usr/bin
endef

$(eval $(call BuildPackage,rlwrap))
