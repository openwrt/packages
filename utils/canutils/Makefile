#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=canutils
PKG_VERSION:=2021.08.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/linux-can/can-utils/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=c9b8f29515ad34af7f78450ec55c983abc5393e86b1f128a92ac0dfd141baaf7
PKG_BUILD_DIR:=$(BUILD_DIR)/can-utils-$(PKG_VERSION)

PKG_MAINTAINER:=Anton Glukhov <anton.a.glukhov@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/canutils/Default
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=https://github.com/linux-can/can-utils
  TITLE:=CAN userspace utilities and tools
endef

define Package/canutils
  $(call Package/canutils/Default)
  MENU:=1
endef

define GenPlugin
  define Package/$(addprefix canutils-,$(1))
    $(call Package/canutils/Default)
    TITLE:=Utility $(1) from the CAN utilities
    DEPENDS:=canutils
  endef

   define Package/$(addprefix canutils-,$(1))/description
     Utility $(1) from the CAN utilities package.
   endef
endef

FILES:= \
	asc2log bcmserver canbusload can-calc-bit-timing \
	candump canfdtest cangen cangw canlogserver canplayer \
	cansend cansniffer isotpdump isotpperf isotprecv isotpsend \
	isotpserver isotpsniffer isotptun j1939acd j1939cat j1939spy j1939sr \
	log2asc log2long slcan_attach slcand slcanpty testj1939

$(foreach a,$(FILES),$(eval $(call GenPlugin,$(a))))

define PartInstall
define Package/canutils-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/bin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/$(1) \
		$$(1)/usr/bin/
endef
endef

$(foreach file,$(FILES),$(eval $(call PartInstall,$(file))))

define Package/canutils/install
	true
endef

$(eval $(call BuildPackage,canutils))
$(foreach file,$(FILES),$(eval $(call BuildPackage,canutils-$(file))))
