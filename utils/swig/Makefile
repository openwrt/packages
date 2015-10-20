# 
# Copyright (C) 2006-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=swig
PKG_VERSION:=3.0.7

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/$(PKG_NAME)
PKG_MD5SUM:=7fff46c84b8c630ede5b0f0827e3d90a
PKG_INSTALL:=1

PKG_MAINTAINER:=John Crispin <blogic@openwrt.org>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILE:=LICENSE

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/swig
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=swig binding generator
  BUILDONLY:=1
endef

HOST_CONFIGURE_ARGS+= \
	--without-pcre

define Package/swig/description
  tool that generates bindings for various languages
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,swig))
