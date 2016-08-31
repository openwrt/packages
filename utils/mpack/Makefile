#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mpack
PKG_VERSION:=1.6
PKG_RELEASE:=1
PKG_LICENSE:=NLPL

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://ftp.andrew.cmu.edu/pub/mpack/
PKG_MD5SUM:=a70fa5afa76539a9afb70b9d81568fe8

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/mpack
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=mpack/munpack MIME format mail messages
  URL:=http://ftp.andrew.cmu.edu/pub/mpack/
  MAINTAINER:=Dmitry V. Zimin <pfzim@mail.ru>
endef

define Package/mpack/description
  Mpack and munpack are utilities for encoding and decoding
  (respectively) binary files in MIME (Multipurpose Internet Mail
  Extensions) format mail messages.  For compatibility with older forms
  of transferring binary files, the munpack program can also decode
  messages in split-uuencoded format.
endef

define Package/mpack/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,mpack))

