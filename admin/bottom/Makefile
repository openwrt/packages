# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Luca Barbato

include $(TOPDIR)/rules.mk

PKG_NAME:=bottom
PKG_VERSION:=0.11.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-vendor.tar.zst
PKG_SOURCE_URL:=@OPENWRT
PKG_SOURCE_PROTO:=cargo-vendor-github
PKG_VENDOR_REPO:=ClementTsang/bottom
PKG_VENDOR_TAG:=$(PKG_VERSION)
PKG_VENDOR_HASH:=0095ea9edb386ad7c49d845176314097713661d22ec42314e3be46426bc769ee
PKG_HASH:=2154c30f6ffbdbd432f854d59e67ef731e2740eb45e83ad4363118b9ae81cbe4

PKG_MAINTAINER:=Luca Barbato <lu_zero@luminem.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/rust-package.mk

define Package/bottom
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Interactive processes viewer
  DEPENDS:=$(RUST_PKG_DEPENDS)
  URL:=https://github.com/ClementTsang/bottom
endef

define Package/bottom/description
  A customizable cross-platform graphical process/system monitor
  for the terminal.
endef

$(eval $(call RustBinPackage,bottom))
$(eval $(call BuildPackage,bottom))
