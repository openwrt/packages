# SPDX-License-Identifier: MIT
#
# Copyright (C) 2025 Nate Robinson

include $(TOPDIR)/rules.mk

PKG_NAME:=lf
PKG_VERSION:=39
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/gokcehan/lf.git
PKG_SOURCE_VERSION:=r$(PKG_VERSION)
PKG_MIRROR_HASH:=abbff226ee3f2374e8c9d65e3f2bff917271694ad01f3a9c0fa0c07065fc4bd7

PKG_MAINTAINER:=Nate Robinson <nrobinson2000@me.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/gokcehan/lf
GO_PKG_LDFLAGS_X:=main.gVersion=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/lf
  SUBMENU:=Filesystem
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Terminal file manager
  URL:=https://github.com/gokcehan/lf
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/lf/description
  lf (as in "list files") is a terminal file manager written in Go
  with a heavy inspiration from the ranger file manager.
endef

$(eval $(call GoBinPackage,lf))
$(eval $(call BuildPackage,lf))
