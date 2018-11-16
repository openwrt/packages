#
# Copyright (C) 2016 Ben Rosser <rosser.bjr@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=quassel-irssi

# quassel-irssi upstream doesn't release versions (at least, at the moment),
# so use commit date for PKG_VERSION and embed commit hash into PKG_RELEASE.
PKG_VERSION:=2017-01-17
PKG_SOURCE_VERSION:=19e810405789a35b92026b56ea49d01a3f544b07
PKG_RELEASE:=1.$(PKG_SOURCE_VERSION)

PKG_LICENSE:=GPL-3.0+

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/phhusson/quassel-irssi
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.xz
PKG_MIRROR_HASH:=5ad9416ce4d522dc3bb1b487063339f559928dcefa8aef4ce88ab93d5f4d5352

PKG_MAINTAINER:=Ben Rosser <rosser.bjr@gmail.com>

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

MAKE_PATH := core
MAKE_VARS += IRSSI_CFLAGS="$(TARGET_CFLAGS) $(EXTRA_CFLAGS) $(TARGET_CPPFLAGS) $(EXTRA_CPPFLAGS)" IRSSI_INCLUDE=$(STAGING_DIR)/usr/include/irssi

define Package/quassel-irssi
    SECTION:=net
    CATEGORY:=Network
    DEPENDS:=+irssi
    SUBMENU:=Instant Messaging
    URL:=https://github.com/phhusson/quassel-irssi
    TITLE:=An irssi plugin to connect to quassel core
endef

define Package/quassel-irssi/description
  An irssi plugin that supports connecting to a quassel core.
endef

define Package/quassel-irssi/install
	$(INSTALL_DIR) $(1)/usr/lib/irssi/modules/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/irssi/modules/libquassel_core.so* $(1)/usr/lib/irssi/modules/
endef

$(eval $(call BuildPackage,quassel-irssi))
