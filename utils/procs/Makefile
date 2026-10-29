# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2026 Facundo Acevedo

include $(TOPDIR)/rules.mk

PKG_NAME:=procs
PKG_VERSION:=0.14.12
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-vendor.tar.zst
PKG_SOURCE_URL:=@OPENWRT
PKG_SOURCE_PROTO:=cargo-vendor-github
PKG_VENDOR_REPO:=dalance/procs
PKG_VENDOR_TAG:=v$(PKG_VERSION)
PKG_VENDOR_HASH:=f2fab583fe98a9ae9505c5eecf4f3d9d4ad9bcb5d478a8222d52c87aa1ac602e
PKG_HASH:=eb5ba2fd63e74327dcbad3232361a1223086a033630e2e7ba2e7ffa1aa58de26

PKG_MAINTAINER:=Facundo Acevedo <facevedo@disroot.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENCE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/rust-package.mk

define Package/procs
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Procs is feature-rich alternative to the 'ps'
  DEPENDS:=$(RUST_PKG_DEPENDS)
  URL:=https://github.com/dalance/procs/
endef

define Package/procs/description
  Procs is a 'ps' command replacement written in Rust, offering
  enhanced usability and information display.
  Features include color-coded output, theme auto-detection, advanced
  search, and extended process details
  (TCP/UDP ports, Docker names, I/O throughput).
  It also supports pager functionality, a 'top'-like watch mode, and
  a process tree view​​.
endef

define Package/procs/conffiles
/etc/procs/procs.toml
endef

define Package/procs/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/procs $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/procs
	$(INSTALL_CONF) ./files/etc/procs/procs.toml $(1)/etc/procs/
endef

$(eval $(call RustBinPackage,procs))
$(eval $(call BuildPackage,procs))
