# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Paul Spooren <mail@aparcar.org>

include $(TOPDIR)/rules.mk

PKG_NAME:=rosenpass
PKG_VERSION:=0.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rosenpass/rosenpass/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=11ed1f8d91ce7dbfc905293306c93aebf54d55a342f325b62f0d6bd0634c69d0

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/rosenpass
  SECTION:=net
  CATEGORY:=Network
  TITLE:=PQC for WireGuard
  DEPENDS:=$(RUST_ARCH_DEPENDS) +libsodium +liboqs
  URL:=https://github.com/rosenpass/rosenpass
endef

define Package/rosenpass/description
  Rosenpass is a post-quantum secure VPN that uses WireGuard to transport the
  actual data.
endef

$(eval $(call RustBinPackage,rosenpass))
$(eval $(call BuildPackage,rosenpass))
