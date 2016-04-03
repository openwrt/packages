#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lpc21isp
PKG_VERSION:=197
PKG_RELEASE:=1
PKG_LICENSE:=LGPL-3.0+
PKG_LICENSE_FILES:=README gpl.txt lgpl-3.0.txt

PKG_BUILD_DIR:=$(BUILD_DIR)/lpc21isp_$(PKG_VERSION)
PKG_SOURCE:=lpc21isp_$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/lpc21isp
PKG_MD5SUM:=0b286859a05a725647ecb1b3fe9ba606
PKG_CAT:=zcat

include $(INCLUDE_DIR)/package.mk

define Package/lpc21isp
  SECTION:=base
  CATEGORY:=Development
  TITLE:=Command line ISP for NXP LPC family and ADUC70xx
  URL:=http://lpc21isp.sourceforge.net/
  MAINTAINER:=Emil 'Skeen' Madsen <sovende@gmail.com>
endef

define Package/lpc21isp/description
 Portable command line ISP (In-circuit Programmer) for NXP LPC family
 and Analog Devices ADUC70xx.
endef

define Package/lpc21isp/install
		$(INSTALL_DIR) $(1)/usr/sbin
		$(INSTALL_BIN) $(PKG_BUILD_DIR)/lpc21isp $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,lpc21isp))
