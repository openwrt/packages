#
# Copyright (C) 2018 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=golang-golang-x-net
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/golang/net.git
PKG_SOURCE_VERSION:=afe8f62b1d6bbd81f31868121a50b06d8188e1f9
PKG_SOURCE_DATE:=20180620
PKG_MIRROR_HASH:=9a8bb3bf21ea60121d7e87f1bd1af9effbdcd908f758be99457653172d13eb1e

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1

GO_PKG:=golang.org/x/net
# exclude http2/h2i to break circular dependency with golang-golang-x-crypto-dev
# since there are no other binaries, can skip compilation
GO_PKG_SOURCE_ONLY:=1

include $(INCLUDE_DIR)/package.mk
include ../golang-package.mk

define Package/golang-golang-x-net-dev
$(call GoPackage/GoSubMenu)
  TITLE:=Go supplementary network libraries
  URL:=https://godoc.org/golang.org/x/net
  DEPENDS:=$(GO_ARCH_DEPENDS) +golang-golang-x-text-dev
  PKGARCH:=all
endef

define Package/golang-golang-x-net-dev/description
Supplementary Go networking libraries.
endef

# http2/testdata/draft-ietf-httpbis-http2.xml is a non-free document
# http2/z_spec_test.go uses http2/testdata/draft-ietf-httpbis-http2.xml
define Package/golang-golang-x-net-dev/install
	$(call GoPackage/Package/Install/Src,$(1))

	rm -f $(1)$(GO_PKG_PATH)/src/$(GO_PKG)/http2/testdata/draft-ietf-httpbis-http2.xml
	rmdir $(1)$(GO_PKG_PATH)/src/$(GO_PKG)/http2/testdata/

	rm -f $(1)$(GO_PKG_PATH)/src/$(GO_PKG)/http2/z_spec_test.go
endef

$(eval $(call GoSrcPackage,golang-golang-x-net-dev))
$(eval $(call BuildPackage,golang-golang-x-net-dev))
