#
# Copyright (C) 2021 Gerald Kerma
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=envsubst
PKG_VERSION:=1.2.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/a8m/envsubst
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_DATE:=20200620
PKG_MIRROR_HASH:=f1211e19741e23fb713f97838f9bb342bab8176ecc00fb9976ba2247aef2f9d5

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Gerald Kerma <gandalf@gk2.net>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/a8m/envsubst/cmd/envsubst

GO_PKG_INSTALL_ALL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/envsubst/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Environment variables substitution
  URL:=https://github.com/a8m/envsubst/
endef

define Package/envsubst
$(call Package/envsubst/Default)
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/golang-envsubst-dev
$(call Package/envsubst/Default)
$(call GoPackage/GoSubMenu)
  TITLE+= (source files)
  DEPENDS:=$(GO_ARCH_DEPENDS)
  PKGARCH:=all
endef

define Package/envsubst/Default/description
  Environment variables substitution for Go.
endef

define Package/envsubst/description
$(call Package/envsubst/Default/description)

  This package contains the main program.
endef

define Package/golang-envsubst-dev/description
$(call Package/envsubst/Default/description)

  This package provides the source files for the program.
endef

$(eval $(call GoBinPackage,envsubst))
$(eval $(call BuildPackage,envsubst))

$(eval $(call GoSrcPackage,golang-envsubst-dev))
$(eval $(call BuildPackage,golang-envsubst-dev))

