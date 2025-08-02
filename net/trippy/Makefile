# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=trippy
PKG_VERSION:=0.6.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/fujiapple852/trippy/tar.gz/$(PKG_VERSION)?
PKG_HASH:=4da57c19f4b6a6f3b4426ea066278ad0b0df2d2addae548b839a17fb20c464ae

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host

include ../../lang/rust/rust-package.mk
include $(INCLUDE_DIR)/package.mk

define Build/Compile
	$(call Build/Compile/Cargo)
endef

define Package/trippy
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A network diagnostic tool, inspired by mtr
  DEPENDS:=$(RUST_ARCH_DEPENDS)
  URL:=https://github.com/fujiapple852/trippy
endef

define Package/trippy/description
  Trippy combines the functionality of traceroute and ping and is designed to
  assist with the diagnosis of network issues.
endef

define Package/trippy/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/$(RUSTC_TARGET_ARCH)/stripped/trip $(1)/bin/trip
endef

$(eval $(call BuildPackage,trippy))
