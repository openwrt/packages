#
# Copyright (C) 2006-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=swig
PKG_VERSION:=4.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/$(PKG_NAME)
PKG_HASH:=e8a39cd6437e342cdcbd5af27a9bf11b62dc9efec9248065debcb8276fcbb925
PKG_INSTALL:=1

PKG_MAINTAINER:=John Crispin <blogic@openwrt.org>, Hirokazu MORIKAWA <morikw2@gmail.com>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

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
