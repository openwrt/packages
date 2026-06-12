#
# Copyright (C) 2026 Philip Prindeville <philipp@redfish-solutions.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=quectel-cm
PKG_VERSION:=1.6.0.24
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/kmilo17pet/quectel-cm.git
PKG_MIRROR_HASH:=49f6681f7825aca4e607ffdb4a61e92864dfffc91d404a2f51404a92ef7518d7
PKG_SOURCE_DATE:=2025-08-05
PKG_SOURCE_VERSION:=2c623ffc8a1a8a7054b695956eb343e37b04727b

PKG_MAINTAINER:=Philip Prindeville <philipp@redfish-solutions.com>

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=NOTICE

PKG_CPE_ID:=cpe:/a:quectel-cm:quectel-cm

include $(INCLUDE_DIR)/package.mk

define Package/quectel-cm
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Quectel Connect Manager tool
  DEPENDS:=+libpthread +librt
  URL:=https://github.com/kmilo17pet/quectel-cm.git
endef

define Package/quectel-cm/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/quectel-qmi-proxy $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/quectel-mbim-proxy $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/quectel-CM $(1)/usr/bin/
endef

$(eval $(call BuildPackage,quectel-cm))
