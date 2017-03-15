#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=canutils
PKG_RELEASE=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/linux-can/can-utils
PKG_SOURCE_VERSION:=0e3ff3b3157e456d4b6343f5d4b42ef692bce538
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.bz2
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_SOURCE_VERSION)

PKG_MAINTAINER:=Anton Glukhov <anton.a.glukhov@gmail.com>
PKG_LICENSE:=GPL-2.0+

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

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
    DEPENDS:=canutils
    TITLE:=Utility $(1) from the CAN utilities
  endef

   define Package/$(addprefix canutils-,$(1))/description
     Utility $(1) from the CAN utilities package.
   endef
endef

FILES:=canbusload can-calc-bit-timing candump \
	cangen cangw canplayer cansniffer cansend \
	canfdtest asc2log log2asc log2long bcmserver \
	canlogserver isotpdump isotpperf isotprecv \
	isotpsend isotpserver isotpsniffer isotptun \
	slcan_attach slcand slcanpty


$(foreach a,$(FILES),$(eval $(call GenPlugin,$(a))))

define Package/canutils/install
	true
endef

define PartInstall
define Package/canutils-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/bin
	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/$(1) \
		$$(1)/usr/bin/
endef
endef

$(foreach file,$(FILES),$(eval $(call PartInstall,$(file))))

$(eval $(call BuildPackage,canutils))
$(foreach file,$(FILES),$(eval $(call BuildPackage,canutils-$(file))))
