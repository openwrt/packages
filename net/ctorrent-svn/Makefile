#
# Copyright (C) 2006-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ctorrent-svn
PKG_REV:=322
PKG_VERSION:=r$(PKG_REV)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://svn.code.sf.net/p/dtorrent/code/dtorrent/trunk
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_PROTO:=svn

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)
PKG_CHECK_FORMAT_SECURITY:=0

include $(INCLUDE_DIR)/package.mk

define Package/ctorrent-svn/Default
  SUBMENU:=BitTorrent
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+uclibcxx
  TITLE:=console-based BitTorrent client
  MAINTAINER:=Peter Wagner <tripolar@gmx.at>
  URL:=http://www.rahul.net/dholmes/ctorrent/
endef

define Package/ctorrent-svn/Default/description
	CTorrent is a BitTorrent client written in the C programming language,
	known to be a very robust and mature programming language, which produces
	fast and optimized application.
endef

define Package/ctorrent-svn
$(call Package/ctorrent-svn/Default)
  TITLE+= (with OpenSSL support)
  DEPENDS+=+libopenssl
  VARIANT:=ssl
endef

define Package/ctorrent-svn/description
$(call Package/ctorrent-svn/Default/description)
 This package is built with OpenSSL support.
endef

define Package/ctorrent-svn-nossl
$(call Package/ctorrent-svn/Default)
  TITLE+= (with builtin SHA-1)
  VARIANT:=nossl
endef

define Package/ctorrent-svn-nossl/description
$(call Package/ctorrent-svn/Default/description)
 This package is built with builtin (Steve Reid's public-domain) SHA-1 support
endef

CONFIGURE_VARS += \
	CXX="g++-uc" \
	LIBS="-nodefaultlibs -luClibc++ $(LIBGCC_S) -lc"

ifeq ($(BUILD_VARIANT),ssl)
	CONFIGURE_ARGS += \
		--with-ssl="$(STAGING_DIR)/usr"
endif

ifeq ($(BUILD_VARIANT),nossl)
	CONFIGURE_ARGS += \
		--with-ssl=no
endif

define Build/Configure
	(cd $(PKG_BUILD_DIR); touch \
		configure.ac \
		aclocal.m4 \
		Makefile.in \
		config.h.in \
		configure \
	);
	$(call Build/Configure/Default)
endef

define Package/ctorrent-svn/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ctorrent $(1)/usr/bin/ctorrent
endef

Package/ctorrent-svn-nossl/install = $(Package/ctorrent-svn/install)

$(eval $(call BuildPackage,ctorrent-svn))
$(eval $(call BuildPackage,ctorrent-svn-nossl))
