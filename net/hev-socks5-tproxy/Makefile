include $(TOPDIR)/rules.mk

PKG_NAME:=hev-socks5-tproxy
PKG_VERSION:=2.10.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/heiher/hev-socks5-tproxy/releases/download/$(PKG_VERSION)
PKG_HASH:=4f495a7393afe4b4d36f86e94faddf992def010ff67c02e8ce09693a3a1bd20d

PKG_MAINTAINER:=Ray Wang <git@hev.cc>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=License

PKG_BUILD_FLAGS:=no-mips16
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/hev-socks5-tproxy
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A simple, lightweight socks5 transparent proxy for Linux
  URL:=https://github.com/heiher/hev-socks5-tproxy
endef

define Package/hev-socks5-tproxy/description
hev-socks5-tproxy is a lightweight tool that enables transparent proxying of
network traffic through a SOCKS5 proxy. It’s designed to enhance privacy, bypass
restrictions, and improve connectivity without requiring manual configuration on
client devices.
endef

define Package/hev-socks5-tproxy/conffiles
/etc/config/hev-socks5-tproxy
/etc/hev-socks5-tproxy/
endef

define Package/hev-socks5-tproxy/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/hev-socks5-tproxy $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/hev-socks5-tproxy/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/main.yml $(1)/etc/hev-socks5-tproxy/main.yml

	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) ./files/hev-socks5-tproxy.config $(1)/etc/config/hev-socks5-tproxy

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/hev-socks5-tproxy.init $(1)/etc/init.d/hev-socks5-tproxy
endef

$(eval $(call BuildPackage,hev-socks5-tproxy))
