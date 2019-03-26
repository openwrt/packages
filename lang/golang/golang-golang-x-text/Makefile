#
# Copyright (C) 2018 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=golang-golang-x-text
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/golang/text.git
PKG_SOURCE_VERSION:=5cec4b58c438bd98288aeb248bab2c1840713d21
PKG_SOURCE_DATE:=20180520
PKG_MIRROR_HASH:=6c541a59f32f57afa54a2216045ddf16a077f8fe2e823fbbe77723eca04ddddb

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1

GO_PKG:=golang.org/x/text
# exclude gotext (and message/pipeline) to avoid dependency on golang.org/x/tools
# since there are no other binaries, can skip compilation
GO_PKG_SOURCE_ONLY:=1

include $(INCLUDE_DIR)/package.mk
include ../golang-package.mk

define Package/golang-golang-x-text-dev
$(call GoPackage/GoSubMenu)
  TITLE:=Go text processing support
  URL:=https://godoc.org/golang.org/x/text
  DEPENDS:=$(GO_ARCH_DEPENDS)
  PKGARCH:=all
endef

define Package/golang-golang-x-text-dev/description
Supplementary Go libraries for text processing, many involving Unicode.
endef

$(eval $(call GoSrcPackage,golang-golang-x-text-dev))
$(eval $(call BuildPackage,golang-golang-x-text-dev))
