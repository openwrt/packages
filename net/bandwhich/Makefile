# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=bandwhich
PKG_VERSION:=0.20.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/imsnif/bandwhich/tar.gz/$(PKG_VERSION)?
PKG_HASH:=4bbf05be32439049edd50bd1e4d5a2a95b0be8d36782e4100732f0cc9f19ba12

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.md

PKG_BUILD_DEPENDS:=rust/host

include ../../lang/rust/rust-package.mk
include $(INCLUDE_DIR)/package.mk

define Build/Compile
	$(call Build/Compile/Cargo)
endef

define Package/bandwhich
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Terminal bandwidth utilization tool
  DEPENDS:=$(RUST_ARCH_DEPENDS)
  URL:=https://github.com/imsnif/bandwhich
endef

define Package/bandwhich/description
  bandwhich is a CLI utility for displaying current network utilization by process,
  connection and remote IP/hostname
endef

define Package/bandwhich/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/$(RUSTC_TARGET_ARCH)/stripped/bandwhich $(1)/bin/bandwhich
endef

$(eval $(call BuildPackage,bandwhich))
