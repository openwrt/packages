#
# libnopoll - Makefile for noPoll C WebSocket library
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nopoll
PKG_VERSION:=0.4.6
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ASPLes/nopoll.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=5cf7c10c3b0b758ad254504bf0ae7e600b118528
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.xz
PKG_MIRROR_HASH:=fae82c7c711520be07ed4e9828724d0a8ee5de7d7b4395e4ac9f72da25fcc524

PKG_MAINTAINER:=John Clark <inindev@gmail.com>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/libnopoll
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libopenssl
  TITLE:=noPoll C WebSocket Library
  URL:=http://www.aspl.es/nopoll
endef

define Package/libnopoll/description
  This package contains the noPoll C WebSocket library.
endef

TARGET_LDFLAGS += -lcrypto -lpthread

CONFIGURE_ARGS += \
	--enable-nopoll-log=no \
	--enable-nopoll-doc=no

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/{lib,include}
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnopoll.{a,so*} $(1)/usr/lib/
endef

define Package/libnopoll/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnopoll.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libnopoll))
