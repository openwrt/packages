#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# NOTE: please DO NOT update this package without the maintainer's consent.
# See https://github.com/haiwen/seafile/issues/1119

include $(TOPDIR)/rules.mk

PKG_NAME:=libevhtp
PKG_VERSION:=1.2.16
PKG_RELEASE:=1
PKG_MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/criticalstack/libevhtp/tar.gz/$(PKG_VERSION)?
PKG_HASH:=4c3f510b15873e9fc29299de0c5d4d257d1d910710e104e33439a17c27fc414b

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILE:=LICENSE

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libevhtp
    SECTION:=libs
    CATEGORY:=Libraries
    TITLE:=A more flexible replacement for libevent's httpd API
    MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
    URL:=https://github.com/criticalstack/libevhtp
    DEPENDS:=+libevent2 +libevent2-openssl +libevent2-pthreads +libopenssl +libpthread
endef

define Package/libevhtp/description
   Libevhtp was created as a replacement API for Libevent's current HTTP API.
   The reality of libevent's http interface is that it was created as a JIT server,
   meaning the developer never thought of it being used for creating a full-fledged HTTP service.
endef

include $(INCLUDE_DIR)/cmake.mk

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/{include,lib}
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libevhtp))
