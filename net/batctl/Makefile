# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=batctl
PKG_VERSION:=2026.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://downloads.open-mesh.org/batman/releases/batman-adv-$(PKG_VERSION)
PKG_HASH:=2c8443fae7b3471a500837f8cfbbc2b7bbab602e43ce8c61b100560dec1d9ee0

PKG_MAINTAINER:=Simon Wunderlich <sw@simonwunderlich.de>
PKG_LICENSE:=GPL-2.0-only ISC MIT
PKG_LICENSE_FILES:=LICENSES/preferred/GPL-2.0 LICENSES/preferred/MIT LICENSES/deprecated/ISC

PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=gc-sections lto

include $(INCLUDE_DIR)/package.mk

define Package/batctl/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Wireless
  URL:=https://www.open-mesh.org/
  DEPENDS:=+libnl-tiny +libc +librt
  PROVIDES:=batctl
endef

define Package/batctl/description
  batctl is a more intuitive management utility for B.A.T.M.A.N.-Advanced.
  It is an easier method for configuring batman-adv and provides some
  additional tools for debugging as well. This package builds
  version $(PKG_VERSION) of the user space utility.
endef

define Package/batctl-tiny
  $(call Package/batctl/Default)
  TITLE:=B.A.T.M.A.N. Advanced user space configuration tool (Minimal)
  VARIANT:=tiny
  ALTERNATIVES:=100:/usr/sbin/batctl:/usr/libexec/batctl-tiny
endef

define Package/batctl-tiny/description
  $(Package/batctl/description)
  Only configuration relevant subcommands are enabled.
endef

define Package/batctl-default
  $(call Package/batctl/Default)
  TITLE:=B.A.T.M.A.N. Advanced user space configuration tool (Default)
  VARIANT:=default
  ALTERNATIVES:=200:/usr/sbin/batctl:/usr/libexec/batctl-default
endef

define Package/batctl-default/description
  $(Package/batctl/description)
  Standard subcommands for configuration and online debugging are enabled.
endef

define Package/batctl-full
  $(call Package/batctl/Default)
  TITLE:=B.A.T.M.A.N. Advanced user space configuration tool (Full)
  VARIANT:=full
  ALTERNATIVES:=300:/usr/sbin/batctl:/usr/libexec/batctl-full
endef

define Package/batctl-full/description
  $(Package/batctl/description)
  Subcommands for configuration, online and offline debugging are enabled.
endef

MAKE_VARS += \
	LIBNL_NAME="libnl-tiny" \
	LIBNL_GENL_NAME="libnl-tiny"

MAKE_FLAGS += \
	REVISION="$(PKG_VERSION)-openwrt-$(PKG_RELEASE)"

config-n := \
	aggregation \
	ap_isolation \
	backbonetable \
	bisect_iv \
	bonding \
	bla_backbone_json \
	bla_claim_json \
	bridge_loop_avoidance \
	claimtable \
	dat_cache \
	dat_cache_json \
	distributed_arp_table \
	elp_interval \
	event \
	fragmentation \
	gateways \
	gateways_json \
	gw_mode \
	hardif_json \
	hardifs_json \
	hop_penalty \
	interface \
	isolation_mark \
	loglevel \
	mcast_flags \
	mcast_flags_json \
	mesh_json \
	multicast_fanout \
	multicast_forceflood \
	multicast_mode \
	neighbors \
	neighbors_json \
	orig_interval \
	originators \
	originators_json \
	ping \
	routing_algo \
	statistics \
	tcpdump \
	throughput_override \
	throughputmeter \
	traceroute \
	transglobal \
	translate \
	translocal \
	transtable_global_json \
	transtable_local_json \
	vlan_json \

config-settings := \
	aggregation \
	ap_isolation \
	bonding \
	bridge_loop_avoidance \
	distributed_arp_table \
	elp_interval \
	fragmentation \
	gw_mode \
	hop_penalty \
	interface \
	isolation_mark \
	loglevel \
	multicast_fanout \
	multicast_forceflood \
	multicast_mode \
	orig_interval \
	routing_algo \
	throughput_override \

config-tables := \
	backbonetable \
	claimtable \
	dat_cache \
	gateways \
	mcast_flags \
	neighbors \
	originators \
	statistics \
	transglobal \
	translocal \

config-json := \
	bla_backbone_json \
	bla_claim_json \
	dat_cache_json \
	gateways_json \
	hardif_json \
	hardifs_json \
	mcast_flags_json \
	mesh_json \
	neighbors_json \
	originators_json \
	transtable_global_json \
	transtable_local_json \
	vlan_json \

config-tools := \
	event \
	ping \
	tcpdump \
	throughputmeter \
	traceroute \
	translate \

config-extratools := \
	bisect_iv \

ifeq ($(BUILD_VARIANT),tiny)

config-y := \
	$(config-settings) \

endif

ifeq ($(BUILD_VARIANT),default)

config-y := \
	$(config-settings) \
	$(config-tables) \
	$(config-json) \
	$(config-tools) \

endif

ifeq ($(BUILD_VARIANT),full)

config-y := \
	$(config-settings) \
	$(config-tables) \
	$(config-json) \
	$(config-tools) \
	$(config-extratools) \

endif

MAKE_FLAGS += \
	$(patsubst %,CONFIG_%=n,$(config-n)) \
	$(patsubst %,CONFIG_%=y,$(config-y))

define Package/batctl-tiny/install
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/batctl $(1)/usr/libexec/batctl-tiny
endef

define Package/batctl-default/install
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/batctl $(1)/usr/libexec/batctl-default
endef

define Package/batctl-full/install
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/batctl $(1)/usr/libexec/batctl-full
endef

$(eval $(call BuildPackage,batctl-default))
$(eval $(call BuildPackage,batctl-tiny))
$(eval $(call BuildPackage,batctl-full))
