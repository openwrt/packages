include $(TOPDIR)/rules.mk

PKG_NAME:=coredns
PKG_VERSION:=1.14.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/coredns/coredns.git
PKG_MIRROR_HASH:=f54b8bdb2a0d92aeb09484b9630f481b63005a4ea8d8b32bf07c79522a1b14b3
PKG_SOURCE_VERSION:=v$(PKG_VERSION)

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Vladimir Ermakov <vooon341@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/coredns/coredns
GO_PKG_EXCLUDES:=test
GO_PKG_LDFLAGS_X:= \
	github.com/coredns/coredns/coremain.GitCommit=v$(PKG_VERSION) \
	github.com/coredns/coredns/coremain.gitTag=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/coredns
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=CoreDNS
  URL:=https://coredns.io
  DEPENDS:=$(GO_ARCH_DEPENDS) +COREDNS_PLUGIN_WGSD:kmod-wireguard
  MENU:=1
endef

define Package/coredns/description
  CoreDNS is a fast and flexible DNS server.
  The key word here is flexible: with CoreDNS you are able to do what you want
  with your DNS data by utilizing plugins.
endef

define Package/coredns/config
  source "$(SOURCE)/Config.in"
endef

define Package/coredns/conffiles
/etc/config/coredns
/etc/Corefile
/etc/coredns/
endef

define configure-plugin
	$(SED) '/^$(2):/d' "$(PKG_BUILD_DIR)/plugin.cfg"
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
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_NOMAD),nomad,nomad)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_WGSD),wgsd,github.com/jwhited/wgsd)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_NETBOX),netbox,github.com/oz123/coredns-netbox-plugin)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_FANOUT),fanout,github.com/networkservicemesh/fanout)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_FINALIZE),finalize,github.com/tmeckel/coredns-finalizer)

	cd $(PKG_BUILD_DIR); \
	$(GO_GENERAL_BUILD_CONFIG_VARS) \
	$(GO_PKG_BUILD_CONFIG_VARS) \
	go generate coredns.go

	# NOTE: custom plugins needs go get to pull new dependencies
ifeq ($(CONFIG_COREDNS_REQUIRE_GO_GET),y)
	cd $(PKG_BUILD_DIR); \
	$(GO_GENERAL_BUILD_CONFIG_VARS) \
	$(GO_PKG_BUILD_CONFIG_VARS) \
	go get ./...
endif

endef

define Package/coredns/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/
	$(INSTALL_CONF) $(CURDIR)/files/Corefile $(1)/etc/Corefile
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) $(CURDIR)/files/coredns.conf $(1)/etc/config/coredns
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/coredns.init $(1)/etc/init.d/coredns

	$(INSTALL_DIR) $(1)/etc/coredns/zones/
endef

$(eval $(call BuildPackage,coredns))
