#
# Copyright (C) 2022 Oskari Rauta <oskari.rauta@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nsutils
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rd235/nsutils.git
PKG_SOURCE_DATE:=2022-06-03
PKG_SOURCE_VERSION:=b573702da6d04eb9940b7135b6474b7dd3ec470f
PKG_MIRROR_HASH:=1a83a612a561f590e59900643121a7b9472b594d1c8cbe49475fd0e3e357b4d4

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/nsutils
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Linux namespace utilities
  DEPENDS:=+libcap
  URL:=https://github.com/rd235/nsutils
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
