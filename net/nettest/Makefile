# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2026 Bogdan Radulescu

include $(TOPDIR)/rules.mk

PKG_NAME:=nettest
PKG_VERSION:=2.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/specure/nettest/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=e7e31edb4c68d4222c634a774c2e15b7b4e6e6eeb4d4de7a78c1898004a6cd79

PKG_MAINTAINER:=Bogdan Radulescu <bogdan@nimblex.net>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE.txt

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/nettest
  SECTION:=net
  CATEGORY:=Network
  TITLE:=RMBT throughput, latency and packet loss measurement
  URL:=https://github.com/specure/nettest
  # ring, pulled in by rustls/quinn, refuses to build for the i586 Rust
  # target that OpenWrt uses for ARCH=i386, as it lacks SSE/SSE2.
  DEPENDS:=$(RUST_ARCH_DEPENDS) @!i386
endef

define Package/nettest/description
  nettest measures download and upload throughput, latency, jitter and
  packet loss using the RMBT protocol. The same binary runs as either
  the client or the measurement server it tests against, and also
  serves a browser speed test on the measurement port.
endef

define Package/nettest/conffiles
/etc/nettest.conf
endef

define Package/nettest/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/nettest $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/nettest.init $(1)/etc/init.d/nettest
	$(INSTALL_CONF) $(CURDIR)/files/nettest.conf $(1)/etc/nettest.conf
endef

$(eval $(call RustBinPackage,nettest))
$(eval $(call BuildPackage,nettest))
