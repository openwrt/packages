#
# Copyright (c) 2018-2026 Nick Peng (pymumu@gmail.com)
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=smartdns
PKG_VERSION:=1.2026.48.1
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://www.github.com/pymumu/smartdns.git
PKG_SOURCE_VERSION:=64fc9f20fba0e14cb118fe7f145557971cafd858
PKG_MIRROR_HASH:=2f4c0ea8d3cf7a4616287aa329c3b62d41db81d9a29779bdf8f957870bd44496

SMARTDNS_WEBUI_VERSION:=1.0.0
SMARTDNS_WEBUI_SOURCE_PROTO:=git
SMARTDNS_WEBUI_SOURCE_URL:=https://github.com/pymumu/smartdns-webui.git
SMARTDNS_WEBUI_SOURCE_VERSION:=35cbf4a1940f5dd32670c69bd5cc02437ad073e7
SMARTDNS_WEBUI_HASH:=42e280cbfc168f88690652b85ce919c2aeedc9ef7c4b55122742e484b23492cd
SMARTDNS_WEBUI_FILE:=smartdns-webui-$(SMARTDNS_WEBUI_VERSION).tar.gz
SMARTDNS_WEBUI_BUILD_DIR:=$(PKG_BUILD_DIR)/smartdns-webui

PKG_MAINTAINER:=Nick Peng <pymumu@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

PKG_BUILD_DEPENDS:=PACKAGE_smartdns-ui:rust/host PACKAGE_smartdns-ui:node/host

include ../../lang/rust/rust-package.mk
include $(INCLUDE_DIR)/package.mk

MAKE_VARS += VER=$(PKG_VERSION) 
MAKE_PATH:=src

define Package/smartdns/default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  URL:=https://www.github.com/pymumu/smartdns/
endef

define Package/smartdns
  $(Package/smartdns/default)
  TITLE:=smartdns server
  DEPENDS:=+libpthread +libopenssl +libatomic
endef

define Package/smartdns/description
SmartDNS is a local DNS server which accepts DNS query requests from local network clients,
gets DNS query results from multiple upstream DNS servers concurrently, and returns the fastest IP to clients.
Unlike dnsmasq's all-servers, smartdns returns the fastest IP, and encrypt DNS queries with DoT or DoH. 
endef

define Package/smartdns/conffiles
/etc/config/smartdns
/etc/smartdns/address.conf
/etc/smartdns/blacklist-ip.conf
/etc/smartdns/custom.conf
/etc/smartdns/domain-block.list
/etc/smartdns/domain-forwarding.list
endef

define Package/smartdns/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d 
	$(INSTALL_DIR) $(1)/etc/smartdns $(1)/etc/smartdns/domain-set $(1)/etc/smartdns/conf.d/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/smartdns $(1)/usr/sbin/smartdns
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/package/openwrt/files/etc/init.d/smartdns $(1)/etc/init.d/smartdns
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/address.conf $(1)/etc/smartdns/address.conf
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/blacklist-ip.conf $(1)/etc/smartdns/blacklist-ip.conf
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/custom.conf $(1)/etc/smartdns/custom.conf
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/files/etc/config/smartdns $(1)/etc/config/smartdns
endef

define Package/smartdns-ui
  $(Package/smartdns/default)
  TITLE:=smartdns dashboard
  DEPENDS:=+smartdns $(RUST_ARCH_DEPENDS)
endef

define Package/smartdns-ui/description
A dashboard ui for smartdns server.
endef

define Package/smartdns-ui/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/etc/smartdns/conf.d/
	$(INSTALL_DIR) $(1)/usr/share/smartdns/wwwroot
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/plugin/smartdns-ui/target/smartdns_ui.so $(1)/usr/lib/smartdns_ui.so
	$(CP) $(SMARTDNS_WEBUI_BUILD_DIR)/out/* $(1)/usr/share/smartdns/wwwroot
endef

define Build/Compile/smartdns-webui
	$(STAGING_DIR_HOSTPKG)/bin/npm ci --prefix $(SMARTDNS_WEBUI_BUILD_DIR) --no-audit --no-fund
	$(STAGING_DIR_HOSTPKG)/bin/npm run build --prefix $(SMARTDNS_WEBUI_BUILD_DIR)
endef

define Build/Compile/smartdns-ui
	+$(CARGO_PKG_VARS) CARGO_BUILD_ARGS="$(CARGO_PKG_ARGS)" CC=$(TARGET_CC) \
	$(MAKE) -C $(PKG_BUILD_DIR)/plugin/smartdns-ui
endef

ifdef CONFIG_PACKAGE_smartdns-ui
define Download/smartdns-webui
	FILE:=$(SMARTDNS_WEBUI_FILE)
	PROTO:=$(SMARTDNS_WEBUI_SOURCE_PROTO)
	URL:=$(SMARTDNS_WEBUI_SOURCE_URL)
	MIRROR_HASH:=$(SMARTDNS_WEBUI_HASH)
	VERSION:=$(SMARTDNS_WEBUI_SOURCE_VERSION)
	HASH:=$(SMARTDNS_WEBUI_HASH)
	SUBDIR:=smartdns-webui
endef
$(eval $(call Download,smartdns-webui))

define Build/Prepare
	$(call Build/Prepare/Default)
	$(INSTALL_DIR) $(SMARTDNS_WEBUI_BUILD_DIR)
	$(TAR) -C $(SMARTDNS_WEBUI_BUILD_DIR) --strip-components=1 -xf $(DL_DIR)/$(SMARTDNS_WEBUI_FILE)
endef
endif

define Build/Compile
	$(call Build/Compile/Default,smartdns)
ifdef CONFIG_PACKAGE_smartdns-ui
	$(call Build/Compile/smartdns-ui)
	$(call Build/Compile/smartdns-webui)
endif
endef

$(eval $(call BuildPackage,smartdns))
$(eval $(call BuildPackage,smartdns-ui))
