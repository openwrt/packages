# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Luca Barbato

include $(TOPDIR)/rules.mk

PKG_NAME:=bottom
PKG_VERSION:=0.9.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ClementTsang/bottom/tar.gz/$(PKG_VERSION)?
PKG_HASH:=199123ef354bcabaa8a2e3b7b477b324f5b647d503a2599d08296733846eea6e

PKG_MAINTAINER:=Luca Barbato <lu_zero@luminem.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/bottom
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Interactive processes viewer
  DEPENDS:=$(RUST_ARCH_DEPENDS)
  URL:=https://github.com/ClementTsang/bottom
endef

define Package/bottom/description
  A customizable cross-platform graphical process/system monitor
  for the terminal.
endef

$(eval $(call RustBinPackage,bottom))
$(eval $(call BuildPackage,bottom))
