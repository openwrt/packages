#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ripe-atlas
PKG_VERSION:=5110
PKG_RELEASE:=1

PKG_SOURCE:=ripe-atlas-software-probe-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/RIPE-NCC/ripe-atlas-software-probe/tar.gz/refs/tags/$(PKG_VERSION)?
PKG_HASH:=9ff4931056b7da67e13478c29dfaea0f647ee4cb725f864ba5fa28a33a8ec5c7
PKG_BUILD_DIR:=$(BUILD_DIR)/ripe-atlas-software-probe-$(PKG_VERSION)

PKG_MAINTAINER:=Tiago Gaspar <tiagogaspar8@gmail.com>, Michel Stam <mstam@ripe.net>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/ripe-atlas/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=RIPE Atlas
  URL:=https://atlas.ripe.net/
endef

define Package/ripe-atlas/Default/description
  RIPE Atlas is the RIPE NCC's main Internet data
  collection system. It is a global network of
  devices, called probes and anchors, that
  actively measure Internet connectivity. Anyone
  can access this data via Internet traffic maps,
  streaming data visualisations, and an API.
  RIPE Atlas users can also perform customised
  measurements to gain valuable data about their
  own networks.
endef

# The measurement applets need raw sockets; ujail hands them CAP_NET_RAW from
# capabilities.json, so the probe does not have to run as root.
CONFIGURE_ARGS+= \
	--with-probe-type=generic \
	--with-user=ripe-atlas \
	--with-group=ripe-atlas \
	--with-measurement-user=ripe-atlas \
	--disable-systemd \
	--disable-setcap-install \
	--disable-chown

define Package/ripe-atlas-common
  $(call Package/ripe-atlas/Default)
  TITLE+=(common files)
  USERID:=ripe-atlas=445:ripe-atlas=445
  PROVIDES:=atlas-probe
  DEPENDS:= \
	+jsonfilter \
	+openssh-client \
	+openssh-keygen \
	+libopenssl \
	+@OPENSSL_WITH_DEPRECATED \
	+@BUSYBOX_CONFIG_KILL \
	+@BUSYBOX_CONFIG_KILLALL \
	+@BUSYBOX_CONFIG_PS \
	+@BUSYBOX_CONFIG_SED \
	+@BUSYBOX_CONFIG_TAR \
	+@BUSYBOX_CONFIG_NTPD \
	+@BUSYBOX_CONFIG_BUNZIP2
endef

define Package/ripe-atlas-common/conffiles
/etc/ripe-atlas/mode
/etc/ripe-atlas/probe_key
/etc/ripe-atlas/probe_key.pub
/etc/config/ripe-atlas
endef

define Package/ripe-atlas-common/description
  RIPE Atlas (common files)

  $(call Package/ripe-atlas/Default/description)
endef

define LinkApplet
	$(LN) busybox $(1)/usr/lib/ripe-atlas/measurement/$(2)
endef

define Package/ripe-atlas-common/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ripe-atlas.init $(1)/etc/init.d/ripe-atlas

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/ripe-atlas.conf $(1)/etc/config/ripe-atlas

	$(INSTALL_DIR) $(1)/etc/ripe-atlas

	$(INSTALL_DIR) $(1)/usr/lib/ripe-atlas/measurement
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/measurement/busybox \
		       $(1)/usr/lib/ripe-atlas/measurement/busybox
	$(call LinkApplet,$(1),atlasinit)
	$(call LinkApplet,$(1),buddyinfo)
	$(call LinkApplet,$(1),condmv)
	$(call LinkApplet,$(1),date)
	$(call LinkApplet,$(1),dfrm)
	$(call LinkApplet,$(1),eooqd)
	$(call LinkApplet,$(1),eperd)
	$(call LinkApplet,$(1),evhttpget)
	$(call LinkApplet,$(1),evntp)
	$(call LinkApplet,$(1),evping)
	$(call LinkApplet,$(1),evsslgetcert)
	$(call LinkApplet,$(1),evtdig)
	$(call LinkApplet,$(1),evtraceroute)
	$(call LinkApplet,$(1),httppost)
	$(call LinkApplet,$(1),onlyuptime)
	$(call LinkApplet,$(1),perd)
	$(call LinkApplet,$(1),rchoose)
	$(call LinkApplet,$(1),rptaddrs)
	$(call LinkApplet,$(1),rptra6)
	$(call LinkApplet,$(1),rptuptime)
	$(call LinkApplet,$(1),rxtxrpt)
	$(call LinkApplet,$(1),telnetd)

	$(INSTALL_DIR) $(1)/usr/lib/ripe-atlas/scripts
	$(INSTALL_BIN) -t $(1)/usr/lib/ripe-atlas/scripts \
		$(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/array.lib.sh \
		$(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/atlas_log.lib.sh \
		$(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/class.lib.sh \
		$(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/common-pre.sh \
		$(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/common.sh \
		$(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/config.sh \
		$(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/generic-ATLAS.sh \
		$(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/generic-common.sh \
		$(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/generic-reginit.sh \
		$(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/json.lib.sh \
		$(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/linux-functions.sh \
		$(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/paths.lib.sh \
		$(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/reg_servers.sh.dev \
		$(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/reg_servers.sh.test \
		$(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/reginit.sh \
		$(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/resolvconf \
		$(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/support.lib.sh

	$(INSTALL_DIR) $(1)/usr/share/ripe-atlas
	$(INSTALL_DATA) ./files/capabilities.json $(1)/usr/share/ripe-atlas/capabilities.json
	$(INSTALL_DATA) -t $(1)/usr/share/ripe-atlas \
		$(PKG_INSTALL_DIR)/usr/share/ripe-atlas/FIRMWARE_APPS_VERSION
	$(INSTALL_CONF) -t $(1)/usr/share/ripe-atlas \
		$(PKG_INSTALL_DIR)/usr/share/ripe-atlas/measurement.conf

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ripe-atlas $(1)/usr/sbin/ripe-atlas
endef

define Package/ripe-atlas-probe
  $(call Package/ripe-atlas/Default)
  TITLE+=(Software Probe)
  DEPENDS+=+ripe-atlas-common
  PROVIDES:=atlas-sw-probe
  VARIANT:=probe
  CONFLICTS+=ripe-atlas-anchor
endef

define Package/ripe-atlas-probe/description
  RIPE Atlas (Software Probe)

  $(call Package/ripe-atlas/Default/description)
endef

define Package/ripe-atlas-probe/install
	$(INSTALL_DIR) $(1)/usr/lib/ripe-atlas/scripts
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/config/probe/reg_servers.sh.prod \
		$(1)/usr/lib/ripe-atlas/scripts

	$(INSTALL_DIR) $(1)/usr/share/ripe-atlas
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/config/probe/known_hosts.reg \
		$(1)/usr/share/ripe-atlas
endef

define Package/ripe-atlas-anchor
  $(call Package/ripe-atlas/Default)
  TITLE+=(Anchor)
  DEPENDS+=+ripe-atlas-common
  VARIANT:=anchor
endef

define Package/ripe-atlas-anchor/description
  RIPE Atlas (Anchor)

  $(call Package/ripe-atlas/Default/description)
endef

define Package/ripe-atlas-anchor/install
	$(INSTALL_DIR) $(1)/usr/lib/ripe-atlas/scripts
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/config/anchor/reg_servers.sh.prod \
		$(1)/usr/lib/ripe-atlas/scripts

	$(INSTALL_DIR) $(1)/usr/share/ripe-atlas
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/config/anchor/known_hosts.reg \
		$(1)/usr/share/ripe-atlas
endef

$(eval $(call BuildPackage,ripe-atlas-common))
$(eval $(call BuildPackage,ripe-atlas-anchor))
$(eval $(call BuildPackage,ripe-atlas-probe))
