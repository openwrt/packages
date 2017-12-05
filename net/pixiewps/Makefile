# Copyright (C) 2017 Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=pixiewps
PKG_VERSION:=1.4.1
PKG_RELEASE:=1
PKG_MAINTAINER:=Yousong Zhou <yszhou4tech@gmail.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/wiire-a/pixiewps/releases/download/v$(PKG_VERSION)
PKG_HASH:=8b61b9d94e26c07ab08a01eacd200576375c08139f9d781b5fdbb587ddd33528

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE.md

include $(INCLUDE_DIR)/package.mk
MAKE_PATH:=src

define Package/pixiewps
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=wireless
  TITLE:=An offline WPS bruteforce utility
  URL:=https://github.com/wiire-a/pixiewps
  DEPENDS:=+libpthread
endef

define Package/pixiewps/description
  Pixiewps is a tool written in C used to bruteforce offline the WPS PIN
  exploiting the low or non-existing entropy of some Access Points, the so-called
  "pixie-dust attack" discovered by Dominique Bongard in summer 2014.  It is
  meant for educational purposes only.
endef

define Package/pixiewps/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/pixiewps $(1)/usr/bin/
endef

$(eval $(call BuildPackage,pixiewps))
