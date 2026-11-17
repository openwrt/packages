# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Luca Barbato and Donald Hoskins

include $(TOPDIR)/rules.mk

PKG_NAME:=ripgrep
PKG_VERSION:=15.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/BurntSushi/ripgrep/tar.gz/$(PKG_VERSION)?
PKG_HASH:=046fa01a216793b8bd2750f9d68d4ad43986eb9c0d6122600f993906012972e8

PKG_MAINTAINER:=Luca Barbato <lu_zero@luminem.org>
PKG_LICENSE:=MIT Unlicense
PKG_LICENSE_FILES:=LICENSE-MIT UNLICENSE
PKG_CPE_ID:=cpe:/a:ripgrep_project:ripgrep

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

RUST_PKG_FEATURES:=pcre2

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

## Force pcre2-sys crate to link dynamically with libpcre2
export PCRE2_SYS_STATIC=0
## Most optimized profile
CARGO_PKG_PROFILE:=release-lto

define Package/ripgrep
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=ripgrep (rg) regex grep
  DEPENDS:=$(RUST_ARCH_DEPENDS) +libpcre2
  URL:=https://github.com/BurntSushi/ripgrep
endef

define Package/ripgrep/description
  ripgrep (rg) recursively searches directories for a regex pattern
  while respecting your gitignore
endef

$(eval $(call RustBinPackage,ripgrep))
$(eval $(call BuildPackage,ripgrep))
