include $(TOPDIR)/rules.mk

PKG_NAME:=hev-socks5-server
PKG_VERSION:=2.10.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/heiher/hev-socks5-server/releases/download/$(PKG_VERSION)
PKG_HASH:=94d1335b6d02e641d1794281f94f5e9e256b71d96bff5e92cf1d76d466a6a545

PKG_MAINTAINER:=Ray Wang <git@hev.cc>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=License

PKG_BUILD_FLAGS:=no-mips16
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/hev-socks5-server
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A high-performance socks5 server for Unix
  URL:=https://github.com/heiher/hev-socks5-server
endef

define Package/hev-socks5-server/conffiles
/etc/config/hev-socks5-server
/etc/hev-socks5-server/
endef

define Package/hev-socks5-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/hev-socks5-server $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/hev-socks5-server/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/main.yml $(1)/etc/hev-socks5-server/main.yml
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/auth.txt $(1)/etc/hev-socks5-server/auth.txt

	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) ./files/hev-socks5-server.config $(1)/etc/config/hev-socks5-server

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/hev-socks5-server.init $(1)/etc/init.d/hev-socks5-server
endef

$(eval $(call BuildPackage,hev-socks5-server))
