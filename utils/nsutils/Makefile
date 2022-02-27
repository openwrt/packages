#
# Copyright (C) 2016 Rafał Miłecki <rafal@milecki.pl>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nsutils
PKG_VERSION:=0.2
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rd235/nsutils.git
PKG_SOURCE_DATE:=2022-02-27
PKG_SOURCE_VERSION:=d70867d11d455c19aece0c75791dae5c40b88ca6
PKG_MIRROR_HASH:=94b33cde9240bad9803e2c796437d59c57405e3da95cdb762c9ba8fe041e9643

PKG_FIXUP:=autoreconf
PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/nsutils
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Linux namespace utilities
  DEPENDS:=+libbsd +libcap
endef

define Package/nsutils/description
  Nsutils suite includes a number of utilities to list, add/remove tag, and join namespaces.
endef

define Package/nsutils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/{netnsjoin,nshold,nslist,nsrelease} $(1)/usr/bin/
	$(LN) cgroupnshold $(1)/usr/bin/cgroupnshold
	$(LN) nslist $(1)/usr/bin/cgroupnslist
	$(LN) nsrelease $(1)/usr/bin/cgroupnsrelease
	$(LN) nshold $(1)/usr/bin/ipcnshold
	$(LN) nslist $(1)/usr/bin/ipcnslist
	$(LN) nsrelease $(1)/usr/bin/ipcnsrelease
	$(LN) nshold $(1)/usr/bin/mntnshold
	$(LN) nslist $(1)/usr/bin/mntnslist
	$(LN) nsrelease $(1)/usr/bin/mntnsrelease
	$(LN) nshold $(1)/usr/bin/netnshold
	$(LN) nslist $(1)/usr/bin/netnslist
	$(LN) nsrelease $(1)/usr/bin/netnsrelease
	$(LN) nshold $(1)/usr/bin/pidnshold
	$(LN) nslist $(1)/usr/bin/pidnslist
	$(LN) nsrelease $(1)/usr/bin/pidnsrelease
	$(LN) nshold $(1)/usr/bin/usernshold
	$(LN) nslist $(1)/usr/bin/usernslist
	$(LN) nsrelease $(1)/usr/bin/usernsrelease
	$(LN) nshold $(1)/usr/bin/utsnshold
	$(LN) nslist $(1)/usr/bin/utsnslist
	$(LN) nsrelease $(1)/usr/bin/utsnsrelease
endef

$(eval $(call BuildPackage,nsutils))
