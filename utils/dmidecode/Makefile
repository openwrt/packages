#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dmidecode
PKG_VERSION:=3.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@SAVANNAH/$(PKG_NAME)
PKG_HASH:=79d76735ee8e25196e2a722964cf9683f5a09581503537884b256b01389cc073
PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/dmidecode
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=@(TARGET_x86||TARGET_x86_64||TARGET_armsr_armv8)
  TITLE:=Displays BIOS information
  URL:=https://www.nongnu.org/dmidecode/
endef

define Package/dmidecode/description
	Dmidecode reports information about your system's hardware
	as described in your system BIOS according to the SMBIOS/DMI
	standard.
endef

MAKE_FLAGS += \
	prefix="/usr"

define Package/dmidecode/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/$(PKG_NAME) $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,dmidecode))
