include $(TOPDIR)/rules.mk

PKG_NAME:=https_dns_proxy
PKG_VERSION:=2019-07-21
PKG_RELEASE=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MIRROR_HASH:=57e9c655622772fdc4031210fd30bb36faa0a0a253aeb31aac1129c641f07b7f
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/aarond10/https_dns_proxy/
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=4e47de7b27bffe153670b7c1c0c29776ea1d6cd6
PKG_MAINTAINER:=Aaron Drew <aarond10@gmail.com>
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/https_dns_proxy
  SECTION:=net
  CATEGORY:=Network
  TITLE:=DNS over HTTPS proxy server
  DEPENDS:=+libcares +libcurl +libev +ca-bundle
endef

define Package/https_dns_proxy/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d ${1}/etc/config
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/https_dns_proxy $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/https_dns_proxy.init $(1)/etc/init.d/https_dns_proxy
	$(INSTALL_CONF) ./files/https_dns_proxy.config $(1)/etc/config/https_dns_proxy
endef

$(eval $(call BuildPackage,https_dns_proxy))
