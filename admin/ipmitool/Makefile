#
# Copyright (C) 2017 Alexander Couzens <lynxis@fe80.eu>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ipmitool
PKG_VERSION:=1.8.19
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://codeberg.org/IPMITool/ipmitool
PKG_SOURCE_VERSION:=IPMITOOL_$(subst .,_,$(PKG_VERSION))
PKG_MIRROR_HASH:=a3f0d3510fc47cbfd752f58084a72a09d0d5b23113bd87bf78ee32e74adcb4bc

PKG_MAINTAINER:=Alexander Couzens <lynxis@fe80.eu>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:ipmitool_project:ipmitool

PKG_FIXUP=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/ipmitool
  SECTION:=admin
  CATEGORY:=Administration
  DEPENDS:=+libopenssl +libncurses +libreadline
  TITLE:=Command-line interface to IPMI-enabled devices
  URL:=https://github.com/ipmitool/ipmitool
endef

define Package/ipmitool/Default/description
	Command-line interface to IPMI-enabled devices
endef

define Package/ipmitool/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ipmitool $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ipmievd $(1)/usr/sbin/
endef

CONFIGURE_ARGS += \
	--enable-intf-lan \
	--enable-intf-lanplus \
	--enable-intf-serial \
	--disable-intf-free \
	--enable-intf-open \
	--enable-intf-imb \
	--enable-ipmishell \
	--disable-registry-download

$(eval $(call BuildPackage,ipmitool))
