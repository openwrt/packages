#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libevent
PKG_VERSION:=1.4.15
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-release-$(PKG_VERSION)-stable
PKG_SOURCE:=release-$(PKG_VERSION)-stable.tar.gz
PKG_SOURCE_URL:=https://github.com/libevent/libevent/archive/
PKG_MD5SUM:=6dce6fe39f133c09ffe63de895805f7f
PKG_MAINTAINER:=Steven Barth <cyrus@openwrt.org>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libevent
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Event notification library (legacy)
  DEPENDS:=+librt
  URL:=http://www.libevent.org
endef

define Package/libevent/description
	The libevent API provides a mechanism to execute a callback function
	when a specific event occurs on a file descriptor or after a timeout
	has been reached. Furthermore, libevent also support callbacks due
	to signals or regular timeouts.

	libevent is meant to replace the event loop found in event driven
	network servers. An application just needs to call event_dispatch()
	and then add or remove events dynamically without having to change
	the event loop.
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)" \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/libevent
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/libevent/
	$(INSTALL_DIR) $(1)/usr/lib/libevent
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.{a,so} $(1)/usr/lib/libevent/
endef

define Package/libevent/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libevent))
