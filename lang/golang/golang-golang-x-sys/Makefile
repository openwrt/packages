#
# Copyright (C) 2018 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=golang-golang-x-sys
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/golang/sys.git
PKG_SOURCE_VERSION:=63fc586f45fe72d95d5240a5d5eb95e6503907d3
PKG_SOURCE_DATE:=20180621
PKG_MIRROR_HASH:=3afe7936fb9fb291ef9b9cfa88f51576cdc19abbd34240232ce284958ac7dbaf

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1

GO_PKG:=golang.org/x/sys
GO_PKG_SOURCE_ONLY:=1

include $(INCLUDE_DIR)/package.mk
include ../golang-package.mk

define Package/golang-golang-x-sys-dev
$(call GoPackage/GoSubMenu)
  TITLE:=Go packages for interaction with the OS
  URL:=https://godoc.org/golang.org/x/sys
  DEPENDS:=$(GO_ARCH_DEPENDS)
  PKGARCH:=all
endef

define Package/golang-golang-x-sys-dev/description
Supplementary Go packages for low-level interactions with the operating
system.
endef

$(eval $(call GoSrcPackage,golang-golang-x-sys-dev))
$(eval $(call BuildPackage,golang-golang-x-sys-dev))
