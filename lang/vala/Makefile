#
# Copyright (C) 2006-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=vala
PKG_VERSION:=0.56.18
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/vala/$(basename $(PKG_VERSION))
PKG_HASH:=f2affe7d40ab63db8e7b9ecc3f6bdc9c2fc7e3134c84ff2d795f482fe926a382

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:gnome:vala

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:=glib2/host
HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/vala
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=C-sharp like language for the GObject system
  URL:=https://wiki.gnome.org/Projects/Vala
  BUILDONLY:=1
endef

define Package/vala/description
  Vala is a C-sharp like language for the GObject system. This package contains
  the Vala-to-C compiler for host.
endef

HOST_CONFIGURE_ARGS += \
	--disable-shared \
	--disable-coverage \
	--disable-debug \
	--disable-valadoc \
	--without-cgraph

HOST_CONFIGURE_VARS += \
	GI_GIRDIR=/dev/null

$(eval $(call HostBuild))
$(eval $(call BuildPackage,vala))
