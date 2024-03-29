#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=httping
PKG_VERSION:=3.5
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/folkertvanheusden/HTTPing
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=70c2a9baeed9fdb69009fcf159a5b7ef133df0b7f6df198ae2ccd1691b4713b8

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/nls.mk

define Package/httping/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Httping is like 'ping' but for http-requests
  URL:=https://www.vanheusden.com/httping/
  DEPENDS:=$(INTL_DEPENDS)
  MAINTAINER:=Marcin Jurkowski <marcin1j@gmail.com>
endef

define Package/httping/Default/description
	Give it an url, and it'll show you how long it takes to connect, send a
	request and retrieve the reply (only the headers). Be aware that the
	transmission across the network also takes time!
endef

define Package/httping
  $(call Package/httping/Default)
  DEPENDS+= +libopenssl
  TITLE+= (with SSL support)
  VARIANT:=ssl
endef

define Package/httping/description
	$(call Package/httping/Default/description)
	This package is built with SSL support.
endef

define Package/httping-nossl
  $(call Package/httping/Default)
  TITLE+= (without SSL support)
  VARIANT:=nossl
endef

define Package/httping-nossl/description
	$(call Package/httping/Default/description)
	This package is built without SSL support.
endef

CMAKE_OPTIONS += \
	-DENABLE_SSL=ON \
	-DENABLE_NCURSES=OFF \
	-DENABLE_FFTW=OFF

ifeq ($(BUILD_VARIANT),nossl)
	CMAKE_OPTIONS += -DENABLE_SSL=OFF
endif

define Build/Install
endef

define Package/httping/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/httping $(1)/usr/bin/
endef

Package/httping-nossl/install = $(Package/httping/install)

$(eval $(call BuildPackage,httping))
$(eval $(call BuildPackage,httping-nossl))
