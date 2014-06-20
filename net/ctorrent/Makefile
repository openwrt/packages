#
# Copyright (C) 2006-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ctorrent
PKG_VERSION:=dnh3.3.2
PKG_RELEASE:=6

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/dtorrent \
	http://www.rahul.net/dholmes/ctorrent/
PKG_MD5SUM:=59b23dd05ff70791cd6449effa7fc3b6

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/ctorrent/Default
  SUBMENU:=BitTorrent
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=$(CXX_DEPENDS)
  TITLE:=console-based BitTorrent client
  MAINTAINER:=Peter Wagner <tripolar@gmx.at>
  URL:=http://www.rahul.net/dholmes/ctorrent/
endef

define Package/ctorrent/Default/description
	CTorrent is a BitTorrent client written in the C programming language,
	known to be a very robust and mature programming language, which produces
	fast and optimized application.
endef

define Package/ctorrent
$(call Package/ctorrent/Default)
  TITLE+= (with OpenSSL support)
  DEPENDS+=+libopenssl
  VARIANT:=ssl
endef

define Package/ctorrent/description
$(call Package/ctorrent/Default/description)
 This package is built with OpenSSL support.
endef

define Package/ctorrent-nossl
$(call Package/ctorrent/Default)
  TITLE+= (with builtin SHA-1)
  VARIANT:=nossl
endef

define Package/ctorrent-nossl/description
$(call Package/ctorrent/Default/description)
 This package is built with builtin (Steve Reid's public-domain) SHA-1 support
endef

CONFIGURE_VARS += \
	CXXFLAGS="$$$$CXXFLAGS -fno-rtti"

ifeq ($(BUILD_VARIANT),ssl)
	CONFIGURE_ARGS += \
		--with-ssl="$(STAGING_DIR)/usr"
endif

ifeq ($(BUILD_VARIANT),nossl)
	CONFIGURE_ARGS += \
		--with-ssl=no
endif

define Package/ctorrent/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/usr/bin/$(PKG_NAME)
endef

Package/ctorrent-nossl/install = $(Package/ctorrent/install)

$(eval $(call BuildPackage,ctorrent))
$(eval $(call BuildPackage,ctorrent-nossl))
