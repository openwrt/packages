# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2024-2025 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=dufs
PKG_VERSION:=0.44.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/sigoden/dufs/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=940fe767946699bdecb9be24700f9abe5a08e913ff7edf1a5388c8a540ff1e0f

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=LICENSE-APACHE LICENSE-MIT

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/dufs
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=A distinctive utility file server
  URL:=https://github.com/sigoden/dufs
  DEPENDS:=$(RUST_ARCH_DEPENDS) @!(i386||mips64) +liblzma
endef

define Package/dufs/description
  Dufs is a distinctive utility file server that supports static
  serving, uploading, searching, accessing control, webdav...
endef

define Package/dufs/conffiles
/etc/config/dufs
endef

define Package/dufs/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/dufs $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/dufs.config $(1)/etc/config/dufs
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/dufs.init $(1)/etc/init.d/dufs
endef

$(eval $(call RustBinPackage,dufs))
$(eval $(call BuildPackage,dufs))
