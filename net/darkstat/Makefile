#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=darkstat
PKG_VERSION:=3.0.719
PKG_RELEASE:=1

PKG_MAINTAINER:=Jean-Michel Lacroix <lacroix@lepine-lacroix.info>

PKG_LICENSE:=GPL-2.0 BSD-ISC
PKG_LICENSE_FILES:=COPYING.GPL LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://unix4lyfe.org/darkstat
PKG_MD5SUM:=963145de05cb21f4d93a9c244beeaea0

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/darkstat
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpcap +zlib
  TITLE:=Network bandwidth monitor
  URL:=http://unix4lyfe.org/darkstat/
endef

define Package/darkstat/description
darkstat is a packet sniffer that runs as a background process on a cable/DSL
router, gathers all sorts of statistics about network usage, and serves them
over HTTP.
endef

define Package/darkstat/conffiles
/etc/config/darkstat
endef

CONFIGURE_ARGS += \
	--disable-debug \
	--with-chroot-dir=/var/empty

TARGET_CFLAGS += -std=gnu99

define Build/Compile
	$(HOSTCC) $(PKG_BUILD_DIR)/static/c-ify.c \
		-o $(PKG_BUILD_DIR)/c-ify
	$(call Build/Compile/Default)
endef

define Package/darkstat/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/darkstat $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/darkstat.init $(1)/etc/init.d/darkstat
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/darkstat.config $(1)/etc/config/darkstat
endef

$(eval $(call BuildPackage,darkstat))
