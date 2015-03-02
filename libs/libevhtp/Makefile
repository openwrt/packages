#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libevhtp
PKG_VERSION:=1.2.10
PKG_RELEASE:=1
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/ellzey/libevhtp/archive/
PKG_MD5SUM:=e7261c7e34654f78047431d169b88806

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libevhtp
    SECTION:=libs
    CATEGORY:=Libraries
    TITLE:=A more flexible replacement for libevent's httpd API
    MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
    URL:=https://github.com/ellzey/libevhtp
    DEPENDS:=+libevent2 +libevent2-openssl +libevent2-pthreads +libopenssl +libpthread
endef

define Package/libevhtp/description
   Libevhtp was created as a replacement API for Libevent's current HTTP API.
   The reality of libevent's http interface is that it was created as a JIT server,
   meaning the developer never thought of it being used for creating a full-fledged HTTP service.
endef

include $(INCLUDE_DIR)/cmake.mk

Hooks/Prepare/Post += delete_source_package

define delete_source_package
	# deleting source package as its filename is ambiguous
	rm -f $(DL_DIR)/$(PKG_SOURCE)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/{include,lib}
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libevhtp.so* $(1)/usr/lib/

endef

define Package/libevhtp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libevhtp.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libevhtp))
