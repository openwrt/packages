# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=icecast-libvorbisidec
PKG_VERSION:=1.2.0-dave
PKG_RELEASE:=1

PKG_SOURCE:=libvorbisidec-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://users.tpg.com.au/davico/openwrt/
PKG_MD5SUM:=cb8e51aab92ef164f8e0e8853f7164fa

PKG_BUILD_DIR:=$(BUILD_DIR)/libvorbisidec-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install
PATCH_DIR=./patches-libvorbisidec

include $(INCLUDE_DIR)/package.mk

define Build/Configure
	$(call Build/Configure/Default, \
		--disable-shared \
		--enable-static \
	)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
endef

define Build/InstallDev
	true
endef

$(eval $(call Build/DefaultTargets))
