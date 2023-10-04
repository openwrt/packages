# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2024 Paul Spooren <mail@aparcar.org>

include $(TOPDIR)/rules.mk

PKG_NAME:=rosenpass
PKG_VERSION:=e92fa55
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rosenpass/rosenpass/tar.gz/$(PKG_VERSION)?
PKG_HASH:=2b46cf58328cd2f6fb9c3f0dd9677a0c773e291f3f7e20a120d857584e94fdc1

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
  DEPENDS:=$(RUST_ARCH_DEPENDS) +libsodium
  URL:=https://github.com/rosenpass/rosenpass
endef

define Package/rosenpass/description
  Rosenpass is a post-quantum secure VPN that uses WireGuard to transport the
  actual data.
endef

Build/Compile = $(call Build/Compile/Cargo,rosenpass)

$(eval $(call RustBinPackage,rosenpass))
$(eval $(call BuildPackage,rosenpass))
