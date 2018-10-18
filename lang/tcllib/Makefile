#
# Copyright (C) 2006-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tcllib
PKG_VERSION:=1.19
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@SF/$(PKG_NAME)
PKG_HASH:=4a4f73cc8aca1d6b625717b0ace61205cddaa7768f5f9a0e160dd62abb4177ef
PKG_MAINTAINER:=Vadim Radovel <vadim@radovel.ru>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=tcl/host

# PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/tcllib
	SUBMENU:=Tcl
	SECTION:=lang
	CATEGORY:=Languages
	DEPENDS:=tcl
	TITLE:=Collection of utility modules for Tcl.
	URL:=https://core.tcl.tk/tcllib
endef

define Package/tcllib/description
This package is intended to be a collection of Tcl packages that provide utility functions useful to a large collection of Tcl programmers.
endef

define Package/tcllib/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) -dR $(PKG_INSTALL_DIR)/usr/lib/$(PKG_NAME)$(PKG_VERSION) \
		$(1)/usr/lib/
endef


$(eval $(call BuildPackage,tcllib))
