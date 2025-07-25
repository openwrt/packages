include $(TOPDIR)/rules.mk

PKG_NAME:=hev-socks5-tunnel
PKG_VERSION:=2.12.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/heiher/hev-socks5-tunnel/releases/download/$(PKG_VERSION)
PKG_HASH:=3d4fcd35a47b3f9b0e69d058a373cc27130a89b2ff1e18dba21a1b70ba6e96dc

PKG_MAINTAINER:=Ray Wang <git@hev.cc>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=License

PKG_BUILD_FLAGS:=no-mips16
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/hev-socks5-tunnel
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A high-performance tun2socks for Unix
  URL:=https://github.com/heiher/hev-socks5-tunnel
endef

define Package/hev-socks5-tunnel/description
hev-socks5-tunnel is a fast and lightweight tool that routes internet traffic
through a SOCKS5 proxy, enhancing privacy and bypassing restrictions. It’s known
for its efficiency, simplicity, and low resource usage, making it ideal for secure
and optimized online connections.
endef

define Package/hev-socks5-tunnel/conffiles
/etc/config/hev-socks5-tunnel
/etc/hev-socks5-tunnel/
endef

define Package/hev-socks5-tunnel/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/hev-socks5-tunnel $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/hev-socks5-tunnel/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/main.yml $(1)/etc/hev-socks5-tunnel/main.yml

	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) ./files/hev-socks5-tunnel.config $(1)/etc/config/hev-socks5-tunnel

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/hev-socks5-tunnel.init $(1)/etc/init.d/hev-socks5-tunnel
endef

$(eval $(call BuildPackage,hev-socks5-tunnel))
