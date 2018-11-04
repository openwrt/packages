#
# Copyright (C) 2018 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=golang-github-dchest-siphash
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/dchest/siphash.git
PKG_SOURCE_VERSION:=4ebf1de738443ea7f45f02dc394c4df1942a126d
PKG_SOURCE_DATE:=20160831
PKG_MIRROR_HASH:=57da99437a6dba8c0b34bb09da48c0b8b1e70391ae0e3563453206794defe051

PKG_LICENSE:=CC0-1.0
PKG_LICENSE_FILES:=README.md
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1

GO_PKG:=github.com/dchest/siphash
GO_PKG_SOURCE_ONLY:=1

include $(INCLUDE_DIR)/package.mk
include ../golang-package.mk

define Package/golang-github-dchest-siphash-dev
$(call GoPackage/GoSubMenu)
  TITLE:=Go implementation of SipHash-2-4
  URL:=https://github.com/dchest/siphash
  DEPENDS:=$(GO_ARCH_DEPENDS)
  PKGARCH:=all
endef

define Package/golang-github-dchest-siphash-dev/description
SipHash-2-4 is a pseudorandom function (a.k.a. keyed hash function)
optimized for speed on short messages.
endef

$(eval $(call GoSrcPackage,golang-github-dchest-siphash-dev))
$(eval $(call BuildPackage,golang-github-dchest-siphash-dev))
