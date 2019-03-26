#
# Copyright (C) 2018 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=golang-github-agl-ed25519
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/agl/ed25519.git
PKG_SOURCE_VERSION:=5312a61534124124185d41f09206b9fef1d88403
PKG_SOURCE_DATE:=20170117
PKG_MIRROR_HASH:=be9e9223e7a15f4c12d9f652f5a50a59c01fd1f87ee73bea0ebfd661b5a7ca9c

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1

GO_PKG:=github.com/agl/ed25519
GO_PKG_SOURCE_ONLY:=1

include $(INCLUDE_DIR)/package.mk
include ../golang-package.mk

define Package/golang-github-agl-ed25519-dev
$(call GoPackage/GoSubMenu)
  TITLE:=Ed25519 signature algorithm for Go
  URL:=https://github.com/agl/ed25519
  DEPENDS:=$(GO_ARCH_DEPENDS) \
    +golang-golang-x-crypto-dev
  PKGARCH:=all
endef

define Package/golang-github-agl-ed25519-dev/description
Ed25519 is a public-key signature system based on elliptic-curve
cryptography.
endef

$(eval $(call GoSrcPackage,golang-github-agl-ed25519-dev))
$(eval $(call BuildPackage,golang-github-agl-ed25519-dev))
