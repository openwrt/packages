# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2023 Facundo Acevedo

include $(TOPDIR)/rules.mk

PKG_NAME:=jql
PKG_VERSION:=7.0.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-jql-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/yamafaktory/jql/tar.gz/$(PKG_NAME)-v$(PKG_VERSION)?
PKG_HASH:=a6f0998865ce00d48ba94eff12d3f7389dfe2d6ce0954296fdc890c9157628a0

PKG_MAINTAINER:=Facundo Acevedo <facevedo@disroot.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE-MIT

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_NAME)-v$(PKG_VERSION)
PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/jql
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=jql is a JSON Query Language tool built with Rust.
  DEPENDS:=$(RUST_ARCH_DEPENDS) 
  URL:=https://github.com/yamafaktory/jql
endef

define Package/jql/description
  JQL is a flexible JSON Query utility written in Rust, aiming to 
  simplify JSON manipulation in the shell.
  It offers a powerful language to navigate through JSON structures,
  and a set of built-in operators and functions for effective data
  retrieval and manipulation.
endef

$(eval $(call RustBinPackage,jql))
Build/Compile=$(call Build/Compile/Cargo,crates/jql)
#$(eval $(call BuildPackage,jql))
