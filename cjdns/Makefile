include $(TOPDIR)/rules.mk

PKG_NAME:=cjdns
PKG_VERSION:=0.16
PKG_RELEASE:=10

PKG_SOURCE_URL:=https://github.com/hyperboria/cjdns.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=55803286b9de8a935dbc86111e312c747ef78318
PKG_LICENSE:=GPL-3.0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.bz2
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_SOURCE_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)

include $(INCLUDE_DIR)/package.mk


define Package/cjdns
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Routing and Redirection
	TITLE:=Encrypted near-zero-conf mesh routing protocol
	URL:=https://github.com/hyperboria/cjdns
	MAINTAINER:=Lars Gierth <larsg@systemli.org>
	DEPENDS:=+kmod-tun +kmod-ipv6 +libnl-tiny +libpthread +librt \
		+libuci-lua +lua-bencode +dkjson +luasocket +lua-sha2
endef

define Package/cjdns/description
	Cjdns implements an encrypted IPv6 network using public-key cryptography \
	for address allocation and a distributed hash table for routing. \
	This provides near-zero-configuration networking, and prevents many \
	of the security and scalability issues that plague existing networks.
endef

define Build/Configure
endef

PKG_DO_VARS:=

ifneq ($(CONFIG_KERNEL_SECCOMP_FILTER),y)
PKG_DO_VARS+= Seccomp_NO=1
endif

ifneq ($(CONFIG_USE_UCLIBC),)
PKG_DO_VARS+= UCLIBC=1
endif

define Build/Compile
	CROSS="true" \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	SYSTEM="linux" \
	TARGET_ARCH="$(CONFIG_ARCH)" \
	SSP_SUPPORT="$(CONFIG_SSP_SUPPORT)" \
	$(PKG_DO_VARS) \
	$(PKG_BUILD_DIR)/do
endef

define Package/cjdns/install
	$(INSTALL_DIR) \
		$(1)/usr/sbin \
		$(1)/usr/bin \
		$(1)/etc/config \
		$(1)/etc/init.d \
		$(1)/etc/uci-defaults \
		$(1)/usr/lib/lua/cjdns

	$(INSTALL_BIN) \
		./files/cjdrouteconf \
		$(1)/usr/bin

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/cjdroute \
		$(1)/usr/sbin

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/publictoip6 \
		$(1)/usr/bin

	$(INSTALL_BIN) \
		./files/cjdns.init \
		$(1)/etc/init.d/cjdns

	$(INSTALL_BIN) \
		./files/cjdns.defaults \
		$(1)/etc/uci-defaults/cjdns

	$(CP) \
		./lua/cjdns/* \
		$(1)/usr/lib/lua/cjdns
endef

define Package/cjdns/postinst
#!/bin/sh
if [ -z $${IPKG_INSTROOT} ] ; then
	( . /etc/uci-defaults/cjdns ) && rm -f /etc/uci-defaults/cjdns
	# TODO: we should have an 'Enable' button instead
	/etc/init.d/cjdns enabled || /etc/init.d/cjdns enable
	exit 0
fi
endef

$(eval $(call BuildPackage,cjdns))
