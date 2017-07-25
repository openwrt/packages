#
<<<<<<< HEAD
# Copyright (C) 2015 OpenWrt.org
=======
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
# Copyright (C) 2017 Yousong Zhou <yszhou4tech@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

# Checklist when bumping versions
#
# - update cipher list by checking src/crypto.c:crypto_init()
# - check if default mode has changed from TCP_ONLY
# - check if ss-rules has been upstreamed
#
# TODO
#
# - add validate type: user
#
PKG_NAME:=shadowsocks-libev
<<<<<<< HEAD
PKG_VERSION:=3.0.6
=======
PKG_VERSION:=3.0.7
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/shadowsocks/shadowsocks-libev/releases/download/v$(PKG_VERSION)
<<<<<<< HEAD
PKG_HASH:=7d9b43b0235a57c115bfe160efd54abef96bffcbfff61c5496e7c2800f0734ca

PKG_MAINTAINER:=Jian Chang <aa65535@live.com>
PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1
=======
PKG_HASH:=024f2ff501e15ad0cd03dcbac5ca1842aad13dbd51788e522818ff4c129dee18

PKG_MAINTAINER:=Yousong Zhou <yszhou4tech@gmail.com>

PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=LICENSE

>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

<<<<<<< HEAD
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
=======

define Package/shadowsocks-libev-config
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=shadowsocks-libev config scripts
  URL:=https://github.com/shadowsocks/shadowsocks-libev
endef

define Package/shadowsocks-libev-config/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/shadowsocks-libev.config $(1)/etc/config/shadowsocks-libev
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/shadowsocks-libev.init $(1)/etc/init.d/shadowsocks-libev
endef


define Package/shadowsocks-libev/Default
  define Package/shadowsocks-libev-$(1)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=shadowsocks-libev $(1)
    URL:=https://github.com/shadowsocks/shadowsocks-libev
    DEPENDS:=+libev +libmbedtls +libpcre +libpthread +libsodium +libudns +shadowsocks-libev-config +zlib
  endef

  define Package/shadowsocks-libev-$(1)/install
	$$(INSTALL_DIR) $$(1)/usr/bin
	$$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/bin/$(1) $$(1)/usr/bin
  endef

endef

SHADOWSOCKS_COMPONENTS:=ss-local ss-redir ss-tunnel ss-server
define shadowsocks-libev/templates
  $(foreach component,$(SHADOWSOCKS_COMPONENTS),
    $(call Package/shadowsocks-libev/Default,$(component))
  )
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
endef
$(eval $(call shadowsocks-libev/templates))

<<<<<<< HEAD
define Package/shadowsocks-libev/install
=======

define Package/shadowsocks-libev-ss-rules
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=shadowsocks-libev ss-rules
  URL:=https://github.com/shadowsocks/shadowsocks-libev
  DEPENDS:=+ip +ipset +iptables-mod-tproxy +shadowsocks-libev-ss-redir +shadowsocks-libev-config
endef

define Package/shadowsocks-libev-ss-rules/install
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/ss-rules $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DATA) ./files/firewall.ss-rules $(1)/etc
	$(INSTALL_BIN) ./files/ss-rules.defaults $(1)/etc/uci-defaults
endef

<<<<<<< HEAD
CONFIGURE_ARGS += --disable-documentation

$(eval $(call BuildPackage,shadowsocks-libev))
=======
define Package/shadowsocks-libev-ss-rules/prerm
#!/bin/sh
s=firewall.ss_rules
uci get "$$s" >/dev/null || exit 0
uci batch <<-EOF
	delete $$s
	commit firewall
EOF
endef

CONFIGURE_ARGS += \
	--disable-documentation \
	--disable-silent-rules \

$(eval $(call BuildPackage,shadowsocks-libev-config))
$(eval $(call BuildPackage,shadowsocks-libev-ss-rules))
$(foreach component,$(SHADOWSOCKS_COMPONENTS), \
  $(eval $(call BuildPackage,shadowsocks-libev-$(component))) \
)
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
