# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=mkfontscale
PKG_VERSION:=1.1.3
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://xorg.freedesktop.org/releases/individual/app/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=1e98df69ee5f4542d711e140e1d93e2c3f2775407ccbb7849110d52b91782a6a

HOST_BUILD_DEPENDS:=libfontenc/host freetype/host util-macros/host
HOST_BUILD_PARALLEL:=1
PKG_HOST_ONLY:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/mkfontscale
  SECTION:=xorg
  CATEGORY:=Xorg
  TITLE:=X.org font scale
  URL:=http://xorg.freedesktop.org/
endef

$(eval $(call BuildPackage,mkfontscale))
$(eval $(call HostBuild))
