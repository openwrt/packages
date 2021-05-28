# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=statik
PKG_VERSION:=0.1.7
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rakyll/statik/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=cd05f409e63674f29cff0e496bd33eee70229985243cce486107085fab747082

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

HOST_BUILD_DEPENDS:=golang/host
HOST_BUILD_PARALLEL:=1

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/rakyll/statik

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-host-build.mk
include ../../lang/golang/golang-package.mk

define Package/statik
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=Embed files into a Go executable
  URL:=https://github.com/rakyll/statik
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/statik/description
  statik allows you to embed a directory of static files into your Go
  binary to be later served from an http.FileSystem.
endef

$(eval $(call GoBinHostBuild))
$(eval $(call HostBuild))
$(eval $(call GoBinPackage,statik))
$(eval $(call BuildPackage,statik))
