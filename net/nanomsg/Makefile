#
# Copyright (C) 2014-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nanomsg
PKG_VERSION:=0.8-beta
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/nanomsg/nanomsg/releases/download/$(PKG_VERSION)/
PKG_MD5SUM:=bfccbcd8c5ea8ccad4ef7ade558eebea
PKG_LICENSE:=MIT/X11
PKG_LICENSE_FILE:=COPYING

PKG_FIXUP:=autoreconf -ivf

# PKG_RELEASE:=beta
# PKG_SOURCE_PROTO:=git
# PKG_SOURCE_URL:=https://github.com/nanomsg/nanomsg.git
# CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk


define Package/nanomsg
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Nanomsg high-performance scalability protocol 
  URL:=http://nanomsg.org/
  MAINTAINER:=Thomas Kee <xsited@yahoo.com>
  DEPENDS:=+libssp +librt +libpthread
endef

define Package/nanomsg/description
   nanomsg is a socket library that provides several common communication patterns. It aims to make the networking layer fast, 
   scalable, and easy to use. Implemented in C, it works on a wide range of operating systems with no further dependencies.
endef


define Package/nanomsg/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/.libs/libnanomsg.so*  $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/nanocat  $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/tcpmuxd  $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,nanomsg))

