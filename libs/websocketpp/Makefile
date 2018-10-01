#
# Copyright (C) 2018 Bruno Randolf (br1@einfach.org)
#

include $(TOPDIR)/rules.mk

PKG_NAME:=websocketpp
PKG_VERSION:=0.8.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-git.tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/zaphoyd/websocketpp.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_MIRROR_HASH:=23811ec9a5530f28f08d3e5cf66ef04d87742ab037ddec4ba90ef469182017b4

PKG_MAINTAINER:=Bruno Randolf <br1@einfach.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=zlib openssl

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_INSTALL:=1

define Package/websocketpp
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=WebSocket++
	URL:=https://www.zaphoyd.com/websocketpp
endef

define Package/websocketpp/description
	WebSocket++ is a header only C++ library that implements RFC6455
	The WebSocket Protocol.
endef

$(eval $(call BuildPackage,websocketpp))
