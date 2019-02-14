#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pcsensor
PKG_VERSION:=1.2.0
PKG_RELEASE:=1
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/shakemid/pcsensor-temper.git
PKG_REV=7c335932cffc918d830dd3611a2def751b024d96
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_LICENSE:=GPL-2.0

PKG_MAINTAINER := Vojtech Ruml <vojtech.ruml@gmail.com>

include $(INCLUDE_DIR)/package.mk
ifeq ($(DUMP),)
  -include $(LINUX_DIR)/.config
  include $(INCLUDE_DIR)/netfilter.mk
  STAMP_CONFIGURED:=$(strip $(STAMP_CONFIGURED))_$(shell grep 'NETFILTER' $(LINUX_DIR)/.config | mkhash md5)
endif

define Package/pcsensor
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libusb-1.0
  TITLE:=USB Thermometer PCSensor
endef

define Package/pcsensor/description
  TEMPer pcsensor command for reading temperature using USB thermometers
  from RDing (www.PCsensor.com). Works with TEMPer2 eg. TEMPer2V1.3,
   TEMPerV1.4.
endef

define Package/pcsensor/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pcsensor $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/udev/rules.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/99-tempsensor.rules $(1)/etc/udev/rules.d/99-tempsensor.rules
endef

$(eval $(call BuildPackage,pcsensor))
