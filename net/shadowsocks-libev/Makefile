#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shadowsocks-libev
PKG_VERSION:=2.2.3
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/shadowsocks/shadowsocks-libev.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)
PKG_SOURCE_VERSION:=2b1eef11973de3f7380401fd20f937e84bc2b756
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MAINTAINER:=Jian Chang <aa65535@live.com>

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_USE_MIPS16:=0
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/shadowsocks-libev/Default
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Lightweight Secured Socks5 Proxy $(2)
	URL:=https://github.com/shadowsocks/shadowsocks-libev
	VARIANT:=$(1)
	DEPENDS:=$(3) +libpthread +ipset +ip +iptables-mod-tproxy
endef

Package/shadowsocks-libev = $(call Package/shadowsocks-libev/Default,openssl,(OpenSSL),+libopenssl)
Package/shadowsocks-libev-polarssl = $(call Package/shadowsocks-libev/Default,polarssl,(PolarSSL),+libpolarssl)

define Package/shadowsocks-libev/description
Shadowsocks-libev is a lightweight secured socks5 proxy for embedded devices and low end boxes.
endef

Package/shadowsocks-libev-polarssl/description = $(Package/shadowsocks-libev/description)

define Package/shadowsocks-libev/conffiles
/etc/config/shadowsocks-libev
endef

Package/shadowsocks-libev-polarssl/conffiles = $(Package/shadowsocks-libev/conffiles)

define Package/shadowsocks-libev/postinst
#!/bin/sh
uci -q batch <<-EOF >/dev/null
	delete firewall.shadowsocks_libev
	set firewall.shadowsocks_libev=include
	set firewall.shadowsocks_libev.type=script
	set firewall.shadowsocks_libev.path=/usr/share/shadowsocks-libev/firewall.include
	set firewall.shadowsocks_libev.reload=1
	commit firewall
EOF
exit 0
endef

Package/shadowsocks-libev-polarssl/postinst = $(Package/shadowsocks-libev/postinst)

ifeq ($(BUILD_VARIANT),polarssl)
	CONFIGURE_ARGS += --with-crypto-library=polarssl
endif

define Package/shadowsocks-libev/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-{redir,tunnel} $(1)/usr/bin
	$(INSTALL_BIN) ./files/ss-rules $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/shadowsocks-libev.config $(1)/etc/config/shadowsocks-libev
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/shadowsocks-libev.init $(1)/etc/init.d/shadowsocks-libev
	$(INSTALL_DIR) $(1)/usr/share/shadowsocks-libev
	$(INSTALL_DATA) ./files/firewall.include $(1)/usr/share/shadowsocks-libev/firewall.include
endef

Package/shadowsocks-libev-polarssl/install = $(Package/shadowsocks-libev/install)

$(eval $(call BuildPackage,shadowsocks-libev))
$(eval $(call BuildPackage,shadowsocks-libev-polarssl))
