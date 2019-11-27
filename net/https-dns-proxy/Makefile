include $(TOPDIR)/rules.mk

PKG_NAME:=https_dns_proxy
PKG_RELEASE=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/aarond10/https_dns_proxy
PKG_SOURCE_DATE:=2019-10-09
PKG_SOURCE_VERSION:=3d20c75c4a17aa569748e63ac169b9274178d573
PKG_MIRROR_HASH:=149839f1db4ab9691db3955de526080a5b731ff8484b06f164497f4e244140da

PKG_MAINTAINER:=Aaron Drew <aarond10@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += -DCLANG_TIDY_EXE=

define Package/https_dns_proxy
  SECTION:=net
  CATEGORY:=Network
  TITLE:=DNS over HTTPS Proxy Server
  DEPENDS:=+libcares +libcurl +libev +ca-bundle
endef

define Package/https_dns_proxy/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d ${1}/etc/config
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/https_dns_proxy $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/https_dns_proxy.init $(1)/etc/init.d/https_dns_proxy
	$(INSTALL_CONF) ./files/https_dns_proxy.config $(1)/etc/config/https_dns_proxy
endef

$(eval $(call BuildPackage,https_dns_proxy))
