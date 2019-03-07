#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=batctl

PKG_VERSION:=2019.0
PKG_RELEASE:=2
PKG_HASH:=997721096ff396644e8d697ea7651e9d38243faf317bcea2661d4139ff58b531

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://downloads.open-mesh.org/batman/releases/batman-adv-$(PKG_VERSION)
PKG_LICENSE:=GPL-2.0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/batctl/Default
  URL:=https://www.open-mesh.org/
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libnl-tiny +libc +librt
  PROVIDES:=batctl
  MAINTAINER:=Simon Wunderlich <sw@simonwunderlich.de>
endef

define Package/batctl-tiny
$(call Package/batctl/Default)
  TITLE:=B.A.T.M.A.N. Advanced user space configuration tool (Minimal)
  VARIANT:=tiny
  PROVIDES:=batctl
  ALTERNATIVES:=100:/usr/sbin/batctl:/usr/libexec/batctl-tiny
endef

define Package/batctl-default
$(call Package/batctl/Default)
  TITLE:=B.A.T.M.A.N. Advanced user space configuration tool (Default)
  VARIANT:=default
  ALTERNATIVES:=200:/usr/sbin/batctl:/usr/libexec/batctl-default
endef

define Package/batctl-full
$(call Package/batctl/Default)
  TITLE:=B.A.T.M.A.N. Advanced user space configuration tool (Full)
  VARIANT:=full
  ALTERNATIVES:=300:/usr/sbin/batctl:/usr/libexec/batctl-full
endef

define Package/batctl/description
batctl is a more intuitive managment utility for B.A.T.M.A.N.-Advanced.
It is an easier method for configuring batman-adv and provides some
additional tools for debugging as well. This package builds
version $(PKG_VERSION) of the user space utility.
endef

# The linker can identify unused sections of a binary when each symbol is stored
# in a separate section. This mostly removes unused linker sections and reduces
# the size by ~3% on mipsel.

TARGET_CFLAGS  += -ffunction-sections -fdata-sections
TARGET_LDFLAGS += -Wl,--gc-sections

# Link-time optimization allows to move parts of the optimization from the single
# source file to the global source view. This is done by emitting the GIMPLE
# representation in each object file and analyzing it again during the link step.

TARGET_CFLAGS  += -flto
TARGET_LDFLAGS += -fuse-linker-plugin

MAKE_BATCTL_ENV += \
        CPPFLAGS="$(TARGET_CPPFLAGS)" \
        CFLAGS="$(TARGET_CFLAGS)" \
        LDFLAGS="$(TARGET_LDFLAGS)" \
        LIBNL_NAME="libnl-tiny" \
        LIBNL_GENL_NAME="libnl-tiny"

MAKE_BATCTL_ARGS += \
        REVISION="$(PKG_BATCTL_SHORTREV)" \
        CC="$(TARGET_CC)" \
        DESTDIR="$(PKG_INSTALL_DIR)" \
        batctl install \
        REVISION="openwrt-$(PKG_VERSION)-$(PKG_RELEASE)"

config-n := \
	aggregation \
	ap_isolation \
	backbonetable \
	bisect_iv \
	bonding \
	bridge_loop_avoidance \
	claimtable \
	dat_cache \
	distributed_arp_table \
	event \
	fragmentation \
	gateways \
	gw_mode \
	hop_penalty \
	interface \
	isolation_mark \
	log \
	loglevel \
	mcast_flags \
	multicast_mode \
	nc_nodes \
	neighbors \
	network_coding \
	orig_interval \
	originators \
	ping \
	routing_algo \
	statistics \
	tcpdump \
	throughputmeter \
	traceroute \
	transglobal \
	translate \
	translocal \

config-settings := \
	aggregation \
	ap_isolation \
	bonding \
	bridge_loop_avoidance \
	distributed_arp_table \
	fragmentation \
	gw_mode \
	hop_penalty \
	interface \
	isolation_mark \
	loglevel \
	multicast_mode \
	network_coding \
	orig_interval \
	routing_algo \

config-tables := \
	backbonetable \
	claimtable \
	dat_cache \
	gateways \
	loglevel \
	nc_nodes \
	neighbors \
	originators \
	statistics \
	transglobal \
	translocal \

config-tools := \
	event \
	log \
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
	$(config-tools) \

endif

ifeq ($(BUILD_VARIANT),full)

config-y := \
	$(config-settings) \
	$(config-tables) \
	$(config-tools) \
	$(config-extratools) \

endif

define ConfigVars
$(subst $(space),,$(foreach opt,$(config-$(1)),CONFIG_$(opt)=$(1)
))
endef

define batctl_config
$(call ConfigVars,n)$(call ConfigVars,y)
endef
$(eval $(call shexport,batctl_config))

define Build/Compile
	$(MAKE_BATCTL_ENV) $(MAKE) -C "$(PKG_BUILD_DIR)" $(MAKE_BATCTL_ARGS) \
		$$$$$(call shvar,batctl_config)
endef

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
