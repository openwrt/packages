#
# Copyright (C) 2009-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=intltool
PKG_LIBVER:=0.40
PKG_VERSION:=$(PKG_LIBVER).6
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@GNOME/intltool/$(PKG_LIBVER)
PKG_HASH:=4d1e5f8561f09c958e303d4faa885079a5e173a61d28437d0013ff5efc9e3b64
PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>

PKG_HOST_ONLY:=1
HOST_FIXUP:=autoreconf

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/intltool
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=set of tools to centralize translation using GNU gettext
  URL:=http://www.freedesktop.org/wiki/Software/intltool
  BUILDONLY:=1
endef

define Package/intltool/description
  intltool is a set of tools to centralize translation of many different
  file formats using GNU gettext-compatible PO files.
endef

$(eval $(call BuildPackage,intltool))
$(eval $(call HostBuild))
