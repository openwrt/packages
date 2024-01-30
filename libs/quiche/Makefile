include $(TOPDIR)/rules.mk

PKG_NAME:=quiche
PKG_VERSION:=0.20.0
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://codeload.github.com/cloudflare/quiche/tar.gz/v${PKG_VERSION}?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=notaclue

PKG_MAINTAINER:=Remi Gacogne <remi.gacogne@powerdns.com>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

include ../../lang/rust/rust-values.mk

MAKE_VARS += RUSTC_TARGET_ARCH=$(RUSTC_TARGET_ARCH)
MAKE_VARS += RUST_TARGET=--target=$(RUSTC_TARGET_ARCH)

PKG_BUILD_DEPENDS:=rust/host

RUST_PKG_FEATURES:=ffi,boringssl-boring-crate

define Package/quiche
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=CloudFlare Quiche
  URL:=https://github.com/cloudflare/quiche
  DEPENDS:=
endef

define Package/quiche/install
  $$(INSTALL_DIR) $$(1)/usr/bin/
  $(CP) $(PKG_BUILD_DIR)/libquiche.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,quiche))
