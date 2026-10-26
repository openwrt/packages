include $(TOPDIR)/rules.mk

PKG_NAME:=coredns
PKG_VERSION:=1.15.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/coredns/coredns.git
PKG_MIRROR_HASH:=93aa34fee51cd478365859810f239e6a86ed4d88c93ca8a48f7a83a48ed1c0bc
PKG_SOURCE_VERSION:=v$(PKG_VERSION)

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Vladimir Ermakov <vooon341@gmail.com>
PKG_CPE_ID:=cpe:/a:coredns.io:coredns

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

# Keep pristine plugin.cfg, so every configure starts from upstream order
define Build/Prepare
	$(call Build/Prepare/Default)
	cp "$(PKG_BUILD_DIR)/plugin.cfg" "$(PKG_BUILD_DIR)/plugin.cfg.orig"
endef

# configure-plugin <enabled> <name> <package> [<anchor> [i|a]]
# plugin.cfg order defines plugin chain order. Built-in plugins keep their
# upstream position; new ones are inserted before (i, default) or after (a)
# <anchor>, or appended at the end if no anchor given.
define configure-plugin
	$(if $(filter y,$(1)),\
		grep -q '^$(2):' "$(PKG_BUILD_DIR)/plugin.cfg" || \
		$(if $(4),\
			{ grep -q '^$(4):' "$(PKG_BUILD_DIR)/plugin.cfg" && \
			$(SED) '/^$(4):/$(or $(5),i) $(2):$(3)' "$(PKG_BUILD_DIR)/plugin.cfg"; },\
			echo "$(2):$(3)" >> "$(PKG_BUILD_DIR)/plugin.cfg"),\
		$(SED) '/^$(2):/d' "$(PKG_BUILD_DIR)/plugin.cfg")
endef

define Build/Configure
	$(call GoPackage/Build/Configure,$(1))
	cp "$(PKG_BUILD_DIR)/plugin.cfg.orig" "$(PKG_BUILD_DIR)/plugin.cfg"

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
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_PROXYPROTO),proxyproto,proxyproto)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_ON),on,github.com/coredns/caddy/onevent)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_NOMAD),nomad,nomad)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_SIIT),siit,siit)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_DYNUPDATE),dynupdate,dynupdate)
	# NOTE: third-party plugins, positioned per upstream recommendations
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_NETBOX),netbox,github.com/oz123/coredns-netbox-plugin,cache,a)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_FINALIZE),finalize,github.com/tmeckel/coredns-finalizer,cache,a)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_MULTICLUSTER),multicluster,github.com/coredns/multicluster,file)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_WGSD),wgsd,github.com/jwhited/wgsd,file)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_GSLB),gslb,github.com/dmachard/coredns-gslb,file)
	$(call configure-plugin,$(CONFIG_COREDNS_PLUGIN_FANOUT),fanout,github.com/networkservicemesh/fanout,forward)

	cd $(PKG_BUILD_DIR); \
	$(GO_GENERAL_BUILD_CONFIG_VARS) \
	$(GO_PKG_BUILD_CONFIG_VARS) \
	go generate coredns.go

	# NOTE: custom plugins needs go get to pull new dependencies
ifeq ($(CONFIG_COREDNS_REQUIRE_GO_GET),y)
	cd $(PKG_BUILD_DIR); \
	$(GO_GENERAL_BUILD_CONFIG_VARS) \
	$(GO_PKG_BUILD_CONFIG_VARS) \
	$(GO_PKG_VARS) \
	go get ./...
endif
ifeq ($(CONFIG_COREDNS_PLUGIN_WGSD),y)
	# wgsd -> wgctrl -> genetlink -> netlink v1.6.2 is incompatible with
	# socket v0.5.x (Sendmsg/Recvmsg gained context.Context); pin to v1.7.2
	cd $(PKG_BUILD_DIR); \
	$(GO_GENERAL_BUILD_CONFIG_VARS) \
	$(GO_PKG_BUILD_CONFIG_VARS) \
	$(GO_PKG_VARS) \
	go get github.com/mdlayher/netlink@v1.7.2
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
