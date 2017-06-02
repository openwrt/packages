#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ipmitool
PKG_VERSION:=1.8.17
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/ipmitool
PKG_MD5SUM:=f7408aa2b40333db0413d4aab6bbe978
PKG_MAINTAINER:=Anton D. Kachalov <mouse@yandex-team.ru>

PKG_LICENSE:=SUN
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/ipmitool
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=IPMItool
  DEPENDS:=+libopenssl
  URL:=https://sourceforge.net/projects/ipmitool/
endef

define Package/ipmitool/description
  IPMItool provides in-band and out-of-band IPMI software
endef

CONFIGURE_ARGS += \
	--disable-intf-{usb,imb,lipmi,bmc,serial,free} \
	--disable-ipmishell
	

define Package/ipmitool/install
	$(INSTALL_DIR) $(1)/usr/bin
	cp -a $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,ipmitool))
