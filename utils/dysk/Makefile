# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2023 Facundo Acevedo

include $(TOPDIR)/rules.mk

PKG_NAME:=dysk
PKG_VERSION:=2.8.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Canop/dysk/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=3e0f3a470539721748d7bc1acc867bdddcb824695b2f766e3a1f230ebac28c2c

PKG_MAINTAINER:=Facundo Acevedo <facevedo@disroot.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENCE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/dysk
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Utility for efficient file and directory management
  DEPENDS:=$(RUST_ARCH_DEPENDS) 
  URL:=https://dystroy.org/dysk
endef

define Package/dysk/description
  Dysk is a command-line tool designed for efficient file and
  directory management in Unix-like environments. It offers a
  streamlined approach to organizing and manipulating files,
  potentially simplifying various file-related tasks.
endef

$(eval $(call RustBinPackage,dysk))
$(eval $(call BuildPackage,dysk))
