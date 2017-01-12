include $(TOPDIR)/rules.mk

PKG_NAME:=https_dns_proxy
PKG_VERSION:=2017-01-07
PKG_RELEASE=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/aarond10/https_dns_proxy/
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=c62ce3f6807a4067230a8bc5ea5a829f532de785
PKG_MAINTAINER:=Aaron Drew <aarond10@gmail.com>
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/https_dns_proxy
  SECTION:=net
  CATEGORY:=Network
  TITLE:=DNS over HTTPS proxy server
  DEPENDS:=+libcares +libcurl +libev
endef

define Package/https_dns_proxy/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d ${1}/etc/config
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/https_dns_proxy $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/https_dns_proxy.init $(1)/etc/init.d/https_dns_proxy
	$(INSTALL_CONF) ./files/https_dns_proxy.config $(1)/etc/config/https_dns_proxy
endef

$(eval $(call BuildPackage,https_dns_proxy))
