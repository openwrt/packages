#
# libnopoll - Makefile for noPoll C WebSocket library
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nopoll
PKG_VERSION:=0.4.2
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ASPLes/nopoll.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=60a81fbd199551ac5dd017b9a44fb46e8530680b
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.xz
PKG_MIRROR_HASH:=ce67b91ea54dda6678321e05a3e584648032a31323409a76df5dd60e7bfd17de

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
