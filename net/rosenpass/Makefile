# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2024 Paul Spooren <mail@aparcar.org>

include $(TOPDIR)/rules.mk

PKG_NAME:=rosenpass
PKG_VERSION:=72f68c9bac3b1b3cd09110493f9b953f6dc29eff
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/aparcar/rosenpass/tar.gz/$(PKG_VERSION)?
PKG_HASH:=145e5cb4da4ce14188b622b99be5704d4a4adce2a732a70512a37740b410d76f

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host bpf-headers

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/bpf.mk
include ../../lang/rust/rust-package.mk

define Package/rosenpass
  SECTION:=net
  CATEGORY:=Network
  TITLE:=PQC for WireGuard
  DEPENDS:=$(RUST_ARCH_DEPENDS) +libsodium +libopenssl
  URL:=https://github.com/rosenpass/rosenpass
endef

define Package/rosenpass/description
  Rosenpass is a post-quantum secure VPN that uses WireGuard to transport the
  actual data.
endef

Build/Compile = $(call Build/Compile/Cargo,rosenpass)

$(eval $(call RustBinPackage,rosenpass))
$(eval $(call BuildPackage,rosenpass))
