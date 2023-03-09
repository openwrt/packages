# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Luca Barbato and Donald Hoskins

include $(TOPDIR)/rules.mk

PKG_NAME:=ripgrep
PKG_VERSION:=13.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/BurntSushi/ripgrep/tar.gz/$(PKG_VERSION)?
PKG_HASH:=0fb17aaf285b3eee8ddab17b833af1e190d73de317ff9648751ab0660d763ed2

PKG_MAINTAINER:=Luca Barbato <lu_zero@luminem.org>
PKG_LICENSE:=MIT Unlicense
PKG_LICENSE_FILES:=LICENSE-MIT UNLICENSE

PKG_BUILD_DEPENDS:=rust/host

include ../../lang/rust/rust-package.mk
include $(INCLUDE_DIR)/package.mk

define Build/Compile
	$(call Build/Compile/Cargo,, --features 'pcre2')
endef

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

define Package/ripgrep/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/$(RUSTC_TARGET_ARCH)/stripped/rg $(1)/bin/rg
endef

$(eval $(call BuildPackage,ripgrep))
