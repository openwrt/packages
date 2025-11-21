# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2023 Facundo Acevedo

include $(TOPDIR)/rules.mk

PKG_NAME:=procs
PKG_VERSION:=0.14.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/dalance/procs/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=a3012bba984faddcf8da2a72d21eb9a7e9be8d5d86a387d321987743b0080a8c

PKG_MAINTAINER:=Facundo Acevedo <facevedo@disroot.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENCE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/procs
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Procs is feature-rich alternative to the 'ps'
  DEPENDS:=$(RUST_ARCH_DEPENDS) 
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
