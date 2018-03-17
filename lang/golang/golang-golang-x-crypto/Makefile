#
# Copyright (C) 2018 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=golang-golang-x-crypto
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/golang/crypto.git
PKG_SOURCE_VERSION:=a49355c7e3f8fe157a85be2f77e6e269a0f89602
PKG_SOURCE_DATE:=20180620
PKG_MIRROR_HASH:=80b16b203736ac56883d0610edbc5981eb78f15b7b35d11b5ca639f7c3814214

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1

GO_PKG:=golang.org/x/crypto
GO_PKG_SOURCE_ONLY:=1

include $(INCLUDE_DIR)/package.mk
include ../golang-package.mk

define Package/golang-golang-x-crypto-dev
$(call GoPackage/GoSubMenu)
  TITLE:=Go supplementary cryptography libraries
  URL:=https://godoc.org/golang.org/x/crypto
  DEPENDS:=$(GO_ARCH_DEPENDS) \
    +golang-golang-x-net-dev \
    +golang-golang-x-sys-dev
  PKGARCH:=all
endef

define Package/golang-golang-x-crypto-dev/description
Supplementary Go cryptography libraries.
endef

$(eval $(call GoSrcPackage,golang-golang-x-crypto-dev))
$(eval $(call BuildPackage,golang-golang-x-crypto-dev))
