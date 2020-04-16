#
# Copyright (C) 2018 Bruno Randolf (br1@einfach.org)
#

include $(TOPDIR)/rules.mk

PKG_NAME:=websocketpp
PKG_VERSION:=0.8.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/zaphoyd/websocketpp/archive/$(PKG_VERSION)/
PKG_HASH:=178899de48c02853b55b1ea8681599641cedcdfce59e56beaff3dd0874bf0286

PKG_MAINTAINER:=Bruno Randolf <br1@einfach.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_INSTALL:=1

define Package/websocketpp
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=WebSocket++
	URL:=https://www.zaphoyd.com/websocketpp
	BUILDONLY:=1
endef

define Package/websocketpp/description
	WebSocket++ is a header only C++ library that implements RFC6455
	The WebSocket Protocol.
endef

$(eval $(call BuildPackage,websocketpp))
