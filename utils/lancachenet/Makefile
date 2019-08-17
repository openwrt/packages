include $(TOPDIR)/rules.mk

PKG_NAME:=lancachenet
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_MAINTAINER:=Gerard Ryan <G.M0N3Y.2503@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/lancachenet
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Monolithic Game Download Cache Init Scripts
  URL:=https://hub.docker.com/r/lancachenet/monolithic
  DEPENDS:=+docker-ce +jq +bash +dnsmasq
endef

define Package/lancachenet/description
Scripts to setup and run the lancachenet/monolithic docker image for caching game downloads.
* Uses default dnsmasq for dns overriding to reduce overhead
endef

Build/Compile=# Nothing to compile, just install the scripts

define Package/lancachenet/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/lancache.init $(1)/etc/init.d/lancache

	$(INSTALL_DIR) $(1)/etc/lancache/
	$(INSTALL_BIN) ./files/cache-domains-config.json $(1)/etc/lancache/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/lancache.conf $(1)/etc/config/lancache
	$(INSTALL_CONF) ./files/haproxy.cfg $(1)/etc/lancache-haproxy.cfg
endef

$(eval $(call BuildPackage,lancachenet))
