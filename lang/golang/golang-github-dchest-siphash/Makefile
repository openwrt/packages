#
# Copyright (C) 2018 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=golang-github-dchest-siphash
PKG_VERSION:=1.2.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/dchest/siphash/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=90c5e8ba62b64b2f76ed58c87dd50456171610049bef51fd71bc593c1744fad2
PKG_BUILD_DIR:=$(BUILD_DIR)/siphash-$(PKG_VERSION)

PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>
PKG_LICENSE:=CC0-1.0
PKG_LICENSE_FILES:=README.md

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
