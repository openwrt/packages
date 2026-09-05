#
# Copyright (c) 2018-2025 Nick Peng (pymumu@gmail.com)
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=smartdns
PKG_VERSION:=48.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-Release$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/pymumu/smartdns/tar.gz/refs/tags/Release$(PKG_VERSION)?
PKG_HASH:=b07abba99e921f262ba47588e12f5b36dd849f79c0145542440eb6b7eed80553
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-Release$(PKG_VERSION)

PKG_MAINTAINER:=Nick Peng <pymumu@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:pymumu:smartdns

PKG_BUILD_PARALLEL:=1

SMARTDNS_WEBUI_VERSION:=1.0.0
SMARTDNS_WEBUI_SOURCE_URL:=https://codeload.github.com/pymumu/smartdns-webui/tar.gz/refs/tags/v$(SMARTDNS_WEBUI_VERSION)?
SMARTDNS_WEBUI_SOURCE:=smartdns-webui-$(SMARTDNS_WEBUI_VERSION).tar.gz
SMARTDNS_WEBUI_HASH:=52b1fe6b0b3dfcfbb79533b7ae113fd52db8364ca20d5a133af592d87166260d

PKG_BUILD_DEPENDS:=PACKAGE_smartdns-ui:rust/host
PKG_BUILD_DEPENDS+=PACKAGE_smartdns-webui:node/host

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

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
  DEPENDS:=+libpthread +libopenssl +libatomic +zlib
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
	$(INSTALL_DIR) $(1)/etc/smartdns/ip-set $(1)/etc/smartdns/download
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/smartdns $(1)/usr/sbin/smartdns
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/package/openwrt/files/etc/init.d/smartdns $(1)/etc/init.d/smartdns
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/address.conf $(1)/etc/smartdns/address.conf
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/blacklist-ip.conf $(1)/etc/smartdns/blacklist-ip.conf
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/custom.conf $(1)/etc/smartdns/custom.conf
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/domain-block.list $(1)/etc/smartdns/domain-block.list
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/domain-forwarding.list $(1)/etc/smartdns/domain-forwarding.list
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
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/plugin/smartdns-ui/target/smartdns_ui.so $(1)/usr/lib/smartdns_ui.so
endef

define Package/smartdns-webui
  $(Package/smartdns/default)
  TITLE:=smartdns dashboard web UI (Frontend)
  DEPENDS:=+smartdns-ui
endef

define Package/smartdns-webui/description
  Static web dashboard frontend assets for smartdns.
endef

define Package/smartdns-webui/install
	$(INSTALL_DIR) $(1)/usr/share/smartdns/wwwroot
	$(CP) $(PKG_BUILD_DIR)/smartdns-webui/out/* $(1)/usr/share/smartdns/wwwroot
endef

ifdef CONFIG_PACKAGE_smartdns-webui
define Download/smartdns-webui
  FILE:=$(SMARTDNS_WEBUI_SOURCE)
  URL:=$(SMARTDNS_WEBUI_SOURCE_URL)
  HASH:=$(SMARTDNS_WEBUI_HASH)
endef
$(eval $(call Download,smartdns-webui))

define Build/Prepare
	$(call Build/Prepare/Default)
	$(TAR) -C $(PKG_BUILD_DIR)/ -xf $(DL_DIR)/$(SMARTDNS_WEBUI_SOURCE)
	mv $(PKG_BUILD_DIR)/smartdns-webui-$(SMARTDNS_WEBUI_VERSION) $(PKG_BUILD_DIR)/smartdns-webui
endef
endif

define Build/Compile/smartdns-ui
	+$(CARGO_PKG_VARS) CC="$(TARGET_CC)" \
	make -C $(PKG_BUILD_DIR)/plugin/smartdns-ui
endef

NPM_TMP:=$(shell mktemp -u XXXXXXXXXX)
NPM_FLAGS := \
	npm_config_cache=$(TMP_DIR)/npm-cache-$(NPM_TMP) \
	npm_config_tmp=$(TMP_DIR)/npm-tmp-$(NPM_TMP)

define Build/Compile/smartdns-webui
	which npm || (echo "npm not found, please install npm first" && exit 1)
	$(NPM_FLAGS) npm ci --prefix $(PKG_BUILD_DIR)/smartdns-webui/
	$(NPM_FLAGS) npm run build --prefix $(PKG_BUILD_DIR)/smartdns-webui/
	rm -rf $(TMP_DIR)/npm-tmp-$(NPM_TMP)
	rm -rf $(TMP_DIR)/npm-cache-$(NPM_TMP)
endef

define Build/Compile
	$(call Build/Compile/Default,smartdns)
	$(if $(CONFIG_PACKAGE_smartdns-ui),$(call Build/Compile/smartdns-ui))
	$(if $(CONFIG_PACKAGE_smartdns-webui),$(call Build/Compile/smartdns-webui))
endef

$(eval $(call BuildPackage,smartdns))
$(eval $(call BuildPackage,smartdns-ui))
$(eval $(call BuildPackage,smartdns-webui))
