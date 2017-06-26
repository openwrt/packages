#
# Copyright (C) 2015 OpenWrt.org
# Copyright (C) 2017 Yousong Zhou <yszhou4tech@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shadowsocks-libev
PKG_VERSION:=3.0.6
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/shadowsocks/shadowsocks-libev/releases/download/v$(PKG_VERSION)
PKG_HASH:=7d9b43b0235a57c115bfe160efd54abef96bffcbfff61c5496e7c2800f0734ca

PKG_MAINTAINER:=Jian Chang <aa65535@live.com>
PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_USE_MIPS16:=0
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/shadowsocks-libev
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Lightweight Secured Socks5 Proxy
	URL:=https://github.com/shadowsocks/shadowsocks-libev
	DEPENDS:=+libev +libmbedtls +libpthread +libsodium +libudns \
		+ipset +ip +iptables-mod-tproxy +libpcre +zlib
endef

define Package/shadowsocks-libev/description
Shadowsocks-libev is a lightweight secured socks5 proxy for embedded devices and low end boxes.
endef

define Package/shadowsocks-libev/conffiles
/etc/config/shadowsocks-libev
endef

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

define Package/shadowsocks-libev/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-{local,redir,tunnel,server,manager} $(1)/usr/bin
	$(INSTALL_BIN) ./files/ss-rules $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/shadowsocks-libev.config $(1)/etc/config/shadowsocks-libev
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/shadowsocks-libev.init $(1)/etc/init.d/shadowsocks-libev
	$(INSTALL_DIR) $(1)/usr/share/shadowsocks-libev
	$(INSTALL_DATA) ./files/firewall.include $(1)/usr/share/shadowsocks-libev/firewall.include
endef

CONFIGURE_ARGS += --disable-documentation

$(eval $(call BuildPackage,shadowsocks-libev))
