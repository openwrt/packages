# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=gperf
PKG_VERSION:=3.1
PKG_RELEASE:=1

PKG_SOURCE_URL:=ftp://ftp.gnu.org/gnu/$(PKG_NAME)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=588546b945bba4b70b6a3a616e80b4ab466e3f33024a352fc2198112cdbb3ae2

HOST_BUILD_PARALLEL:=1
PKG_HOST_ONLY:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/gperf
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=
  TITLE:=Perfect hash function generator
  URL:=https://www.gnu.org/software/gperf/
endef

CONFIGURE_ARGS += \
  --prefix=/usr

define Package/gperf/install
endef

$(eval $(call BuildPackage,gperf))
$(eval $(call HostBuild))
