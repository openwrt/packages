#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libevhtp-1.1
PKG_VERSION:=1.1.7
PKG_RELEASE:=1
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ellzey/libevhtp.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=f70c920d4d8d4146ff662867f47c4b5854045b3c
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

include $(INCLUDE_DIR)/package.mk

define Package/libevhtp-1.1
    SECTION:=libs
    CATEGORY:=Libraries
    TITLE:=A more flexible replacement for libevent's httpd API - compatibility package
    MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
    URL:=https://github.com/ellzey/libevhtp
    DEPENDS:=+libevent2 +libevent2-pthreads +libpthread
endef

define Package/libevhtp-1.1/description
   Libevhtp was created as a replacement API for Libevent's current HTTP API.

   NOTE: This is an older version required for compatibility reasons. The latest version has its own package named "libevhtp".
endef

include $(INCLUDE_DIR)/cmake.mk

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/libevhtp-1.1/
	$(INSTALL_DIR) $(1)/usr/lib/libevhtp-1.1/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libevhtp-1.1))
