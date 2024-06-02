# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2024 Luca Barbato

include $(TOPDIR)/rules.mk

PKG_NAME:=cargo-c
PKG_VERSION:=0.9.32
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/lu-zero/cargo-c/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=a96f3cc6c63d9901c9583083338d50b0132504bb067f68accc17f4116ed01f72

PKG_MAINTAINER:=Luca Barbato <lu_zero@luminem.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

HOST_BUILD_DEPENDS:=rust/host
HOST_BUILD_PARALLEL:=1
PKG_HOST_ONLY:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-host-build.mk

define Package/cargo-c
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Rust
  TITLE:=Build and install rust crates as C libraries
  DEPENDS:=$(RUST_ARCH_DEPENDS)
  URL:=https://github.com/lu-zero/cargo-c
  BUILDONLY:=1
endef

define Package/cargo-c/description
  Build and install crates with C bindings so they appear as normal
  C libraries.
endef

$(eval $(call RustBinHostBuild))
$(eval $(call HostBuild))
$(eval $(call BuildPackage,cargo-c))
