#
# Copyright (C) 2012-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shadowsocks-libev-spec
PKG_VERSION:=2.2.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/shadowsocks/shadowsocks-libev.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)
PKG_SOURCE_VERSION:=4883903e657095b93f88a3a3b9a0dccdffdaa397
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MAINTAINER:=aa65535 <aa65535@live.com>

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_USE_MIPS16:=0
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/shadowsocks-libev-spec/Default
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Lightweight Secured Socks5 Proxy $(2)
	URL:=https://github.com/shadowsocks/shadowsocks-libev
	VARIANT:=$(1)
	DEPENDS:=$(3) +resolveip +ipset +ip +iptables-mod-tproxy
endef

Package/shadowsocks-libev-spec = $(call Package/shadowsocks-libev-spec/Default,openssl,(OpenSSL),+libopenssl)
Package/shadowsocks-libev-spec-polarssl = $(call Package/shadowsocks-libev-spec/Default,polarssl,(PolarSSL),+libpolarssl)

define Package/shadowsocks-libev-spec/description
Shadowsocks-libev is a lightweight secured scoks5 proxy for embedded devices and low end boxes.
endef

Package/shadowsocks-libev-spec-polarssl/description = $(Package/shadowsocks-libev-spec/description)

define Package/shadowsocks-libev-spec/conffiles
/etc/config/shadowsocks
/etc/shadowsocks/config.json
/etc/shadowsocks/ignore.list
endef

Package/shadowsocks-libev-spec-polarssl/conffiles = $(Package/shadowsocks-libev-spec/conffiles)

define Package/shadowsocks-libev-spec/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	uci -q batch <<-EOF >/dev/null
		delete firewall.shadowsocks
		set firewall.shadowsocks=include
		set firewall.shadowsocks.type=script
		set firewall.shadowsocks.path=/usr/share/shadowsocks/firewall.include
		set firewall.shadowsocks.reload=1
		commit firewall
EOF
fi
exit 0
endef

Package/shadowsocks-libev-spec-polarssl/postinst = $(Package/shadowsocks-libev-spec/postinst)

ifeq ($(BUILD_VARIANT),polarssl)
	CONFIGURE_ARGS += --with-crypto-library=polarssl
endif

define Package/shadowsocks-libev-spec/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-{redir,tunnel} $(1)/usr/bin
	$(INSTALL_BIN) ./files/ss-rules $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/shadowsocks.config $(1)/etc/config/shadowsocks
	$(INSTALL_DIR) $(1)/etc/shadowsocks
	$(INSTALL_CONF) ./files/shadowsocks.conf $(1)/etc/shadowsocks/config.json
	$(INSTALL_CONF) ./files/ignore.list $(1)/etc/shadowsocks/ignore.list
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/shadowsocks.init $(1)/etc/init.d/shadowsocks
	$(INSTALL_DIR) $(1)/usr/share/shadowsocks
	$(INSTALL_DATA) ./files/shadowsocks.include $(1)/usr/share/shadowsocks/firewall.include
endef

Package/shadowsocks-libev-spec-polarssl/install = $(Package/shadowsocks-libev-spec/install)

$(eval $(call BuildPackage,shadowsocks-libev-spec))
$(eval $(call BuildPackage,shadowsocks-libev-spec-polarssl))
