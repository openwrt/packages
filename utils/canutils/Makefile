#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=canutils
PKG_VERSION:=2018.02.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/linux-can/can-utils/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=370ad4b19447c29099f7300548f1a3362d6e123c4a6a827dbbd3110bc2c26839
PKG_BUILD_DIR:=$(BUILD_DIR)/can-utils-$(PKG_VERSION)

PKG_MAINTAINER:=Anton Glukhov <anton.a.glukhov@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

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
	jacd jspy jsr testj1939 \
	slcan_attach slcand slcanpty


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

$(eval $(call BuildPackage,canutils))
$(foreach file,$(FILES),$(eval $(call BuildPackage,canutils-$(file))))
