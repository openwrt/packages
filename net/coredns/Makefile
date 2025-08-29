include $(TOPDIR)/rules.mk

PKG_NAME:=coredns
PKG_VERSION:=1.12.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/coredns/coredns.git
PKG_MIRROR_HASH:=b92f015703e6fd39b54f1366980e17065d85d3212248d46c45711e0d745b800f
PKG_SOURCE_VERSION:=v${PKG_VERSION}

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Vladimir Ermakov <vooon341@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/coredns/coredns
GO_PKG_EXCLUDES:=test

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/coredns
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=CoreDNS
  URL:=https://coredns.io
  DEPENDS:=$(GO_ARCH_DEPENDS) +COREDNS_PLUGIN_WGSD:kmod-wireguard
  PROVIDES:=wgsd-coredns
  MENU:=1
endef

define Package/coredns/description
  CoreDNS is a fast and flexible DNS server.
  The key word here is flexible: with CoreDNS you are able to do what you want
  with your DNS data by utilizing plugins.
  If some functionality is not provided out of the box you can add it by writing a plugin.
endef

define Package/coredns/config
  source "$(SOURCE)/Config.in"
endef

define Package/coredns/conffiles
/etc/Corefile
endef

GO_PKG_CUSTOM_LDFLAGS += \
	-w -s \
	-X github.com/coredns/coredns/coremain.GitCommit=v$(PKG_VERSION) \
	-X github.com/coredns/coredns/coremain.gitTag=v$(PKG_VERSION)

define configure-plugin
	sed '/^$(2):/d' -i "$(PKG_BUILD_DIR)/plugin.cfg"
ifeq ($(1),y)
	echo "$(2):$(3)" >> "$(PKG_BUILD_DIR)/plugin.cfg"
endif
endef

define Build/Configure
	$(call GoPackage/Build/Configure,$(1))

	# NOTE: allow to disable unneded heavy plugin
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_GEOIP),geoip,geoip)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_TLS),tls,tls)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_QUIC),quic,quic)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_ROUTE53),route53,route53)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_AZURE),azure,azure)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_CLOUDDNS),clouddns,clouddns)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_K8S_EXTERNAL),k8s_external,k8s_external)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_KUBERNETES),kubernetes,kubernetes)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_ETCD),etcd,etcd)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_GRPC),grpc,grpc)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_ON),on,github.com/coredns/caddy/onevent)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_WGSD),wgsd,github.com/jwhited/wgsd)

	cd $(PKG_BUILD_DIR); \
	$(GO_GENERAL_BUILD_CONFIG_VARS) \
	$(GO_PKG_BUILD_CONFIG_VARS) \
	go generate coredns.go

	cd $(PKG_BUILD_DIR); \
	$(GO_GENERAL_BUILD_CONFIG_VARS) \
	$(GO_PKG_BUILD_CONFIG_VARS) \
	go get ./...

endef

define Package/coredns/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/
	$(INSTALL_CONF) $(CURDIR)/files/Corefile $(1)/etc/Corefile
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/coredns.init $(1)/etc/init.d/coredns
endef

$(eval $(call BuildPackage,coredns))
