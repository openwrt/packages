#
# Copyright (C) 2010-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libprom
PKG_VERSION:=0.1.3
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/digitalocean/prometheus-client-c.git
PKG_MIRROR_HASH:=e3c5d90dff57fca810abd46e65b46ac1205f7049d4022d8244180b68c43b4320

PKG_MAINTAINER:=Vladimir Ermakov <vooon341@gmail.com>
PKG_LICENSE:=Apache-2.0

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

CMAKE_INSTALL:=1
CMAKE_SOURCE_SUBDIR:=prom

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libprom
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Prometheus instrumentation library for C
  URL:=https://github.com/digitalocean/prometheus-client-c
endef

define Package/libprom/description
  This project provides shared libraries for instrumenting software via Prometheus.
endef

define Package/libprom/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libprom.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libprom))
