# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2024 Jonas Jelonek

include $(TOPDIR)/rules.mk

PKG_NAME:=gping
PKG_VERSION:=1.18.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/orf/gping/tar.gz/$(PKG_NAME)-v$(PKG_VERSION)?
PKG_HASH:=a76e09619831c0f2bb95f505a92c1332de89c3c43383b4d832a69afcb0fafd4c

PKG_MAINTAINER:=Jonas Jelonek <jelonek.jonas@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_NAME)-v$(PKG_VERSION)
PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/gping
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Ping but with a graph
  DEPENDS:=$(RUST_ARCH_DEPENDS)
  URL:=https://github.com/orf/gping
endef

define Package/gping/description
  gping graphically plots ping results over time in terminal, allows
  multiple hosts to ping in parallel, uses coloured output and can
  also plot the execution time of arbitrary commands.
endef

MAKE_PATH:=gping

$(eval $(call RustBinPackage,gping))
$(eval $(call BuildPackage,gping))
