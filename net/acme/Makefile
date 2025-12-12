#
# Copyright (C) 2016 Toke Høiland-Jørgensen
#
# This is free software, licensed under the GNU General Public License v3 or
# later.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=acme
PKG_VERSION:=4.0.0

PKG_MAINTAINER:=Toke Høiland-Jørgensen <toke@toke.dk>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE.md

include $(INCLUDE_DIR)/package.mk

define Package/acme
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+acme-acmesh
  TITLE:=Shorthand package for acme-acmesh
  PKGARCH:=all
endef

define Package/acme/description
Shorthand package for acme-acmesh.
endef

define Package/acme/install
	:
endef

define Build/Configure
endef

define Build/Compile
endef

$(eval $(call BuildPackage,acme))
