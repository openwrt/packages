# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2017-2020 Yousong Zhou <yszhou4tech@gmail.com>
# Copyright (C) 2026 Jove Yu <yushijun110@gmail.com>
#
# vim: set noexpandtab ts=8 sw=8 sts=0:

include $(TOPDIR)/rules.mk

PKG_NAME:=shadowsocks-rust
PKG_VERSION:=1.24.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/shadowsocks/shadowsocks-rust/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=a89865d1c5203de1b732017dd032e85f943d1592e8d3152eb7d2c4f3fca387bf

PKG_MAINTAINER:=Jove Yu <yushijun110@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

RUST_PKG_FEATURES:=aead-cipher-2022,local-dns,local-http,local-redir,local-tun,local-tunnel

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/shadowsocks-rust-config
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=shadowsocks-rust config script
	URL:=https://github.com/shadowsocks/shadowsocks-rust
endef

define Package/shadowsocks-rust-config/conffiles
	/etc/config/shadowsocks-rust
endef

define Package/shadowsocks-rust-config/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./shadowsocks-rust.config $(1)/etc/config/shadowsocks-rust
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./shadowsocks-rust.init $(1)/etc/init.d/shadowsocks-rust
endef

define Package/shadowsocks-rust-ssrules
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=shadowsocks-rust ssrules
	URL:=https://github.com/shadowsocks/shadowsocks-rust
	DEPENDS:=+firewall4 \
		+ip \
		+shadowsocks-rust-sslocal \
		+shadowsocks-rust-config \
		+kmod-nft-tproxy
endef

define Package/shadowsocks-rust-ssrules/install
	$(INSTALL_DIR) $(1)/usr/share/shadowsocks-rust/
	$(INSTALL_DATA) ./ssrules/* $(1)/usr/share/shadowsocks-rust/
endef

define Package/shadowsocks-rust/Default
define Package/shadowsocks-rust-$(1)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=shadowsocks-rust $(1)
	URL:=https://github.com/shadowsocks/shadowsocks-rust
	DEPENDS:=$$(RUST_ARCH_DEPENDS) @!i386
endef

define Package/shadowsocks-rust-$(1)/install
	$$(INSTALL_DIR) $$(1)/usr/bin
	$$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/bin/$(1) $$(1)/usr/bin/
endef
endef

SHADOWSOCKS_COMPONENTS:=sslocal ssmanager ssserver ssurl ssservice
define shadowsocks-rust/templates
	$(foreach component,$(SHADOWSOCKS_COMPONENTS),
		$(call Package/shadowsocks-rust/Default,$(component))
	)
endef
$(eval $(call shadowsocks-rust/templates))

$(eval $(call BuildPackage,shadowsocks-rust-config))
$(eval $(call BuildPackage,shadowsocks-rust-ssrules))
$(foreach component,$(SHADOWSOCKS_COMPONENTS), \
	$(eval $(call BuildPackage,shadowsocks-rust-$(component))) \
)


