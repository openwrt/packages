# Copyright (C) 2026 tokisaki galaxy <moebest@outlook.jp>
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=webauthn-helper
PKG_VERSION:=1.0.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/tokisaki-galaxy/webauthn-helper/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=574f72498f5c092a275252a549ea978f766b5b181b4eee1ac9a87c17fdb51ab0

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=tokisaki galaxy <moebest@outlook.jp>

PKG_BUILD_DEPENDS:=rust/host

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/$(PKG_NAME)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=webauthn helper tools for OpenWrt
  URL:=https://github.com/tokisaki-galaxy/webauthn-helper
  DEPENDS:=$(RUST_ARCH_DEPENDS)
endef

define Package/$(PKG_NAME)/description
  This is a webauthn tools written in Rust, optimized for OpenWrt.
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/$(PKG_NAME) $(1)/usr/libexec/
endef

$(eval $(call RustBinPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
