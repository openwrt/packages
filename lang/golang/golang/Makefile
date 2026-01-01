# This is a dummy go package that allows packages to use default go version by
# setting PKG_BUILD_DEPENDS:=golang/host, instead of specifying a concrete
# version, e.g. PKG_BUILD_DEPENDS:=golang1.25/host
#
# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk
include ../golang-values.mk

PKG_NAME:=golang
PKG_VERSION:=$(GO_DEFAULT_VERSION)
PKG_RELEASE:=1

PKG_MAINTAINER:=George Sapkin <george@sapk.in>

HOST_BUILD_DEPENDS:=golang$(PKG_VERSION)/host
PKG_HOST_ONLY:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/golang
  TITLE:=Go programming language (dummy package)
  BUILDONLY:=1
endef

define Host/Compile
endef

define Host/Install
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,golang))
