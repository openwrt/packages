#
# Copyright (C) 2006-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=vala
PKG_VERSION:=0.46.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/vala/0.46
PKG_HASH:=92070393e8102da29e07b29fcb808d021600a25f8a2a69c852470ec8d97740bc

PKG_MAINTAINER:=
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

HOST_BUILD_DEPENDS:=glib2/host
HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/vala
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=C-sharp like language for the GObject system
  URL:=https://wiki.gnome.org/Projects/Vala
endef

define Package/vala/description
  Vala is a C-sharp like language for the GObject system. This package contains
  the Vala-to-C compiler for host.
endef

HOST_CONFIGURE_ARGS += \
	--disable-coverage \
	--disable-debug \
	--disable-valadoc \
	--without-cgraph

$(eval $(call HostBuild))
$(eval $(call BuildPackage,vala))
