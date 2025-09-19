include $(TOPDIR)/rules.mk

PKG_NAME:=ripe-atlas
PKG_VERSION:=5110
PKG_RELEASE:=1

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tiago Gaspar <tiagogaspar8@gmail.com>, Michel Stam <mstam@ripe.net>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/RIPE-NCC/ripe-atlas-software-probe.git
PKG_SOURCE_VERSION:=93adf79ca203734cd531a25a1ada060f3fb7b535
PKG_MIRROR_HASH:=f1f84bb161ab771ae7ecb760c17abad6751a88ace8fd94cc29f7795960859ecd

PKG_FIXUP=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/ripe-atlas/Default
	TITLE:=RIPE Atlas
	SECTION:=net
	CATEGORY:=Network
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

CONFIGURE_ARGS+= \
	--with-probe-type=generic \
	--with-user=root \
	--with-group=ripe-atlas \
	--with-measurement-user=root \
	--disable-systemd \
	--disable-setcap-install \
	--disable-chown


define Package/ripe-atlas-common
	$(call Package/ripe-atlas/Default)
	TITLE+=(common files)
	USERID:=root:ripe-atlas root:ripe-atlas
	DEPENDS+= \
			+e2fsprogs \
			+jsonfilter \
			+openssh-client \
			+openssh-keygen \
			+libopenssl \
			+@OPENSSL_WITH_DEPRECATED \
			+@BUSYBOX_CONFIG_HOSTNAME \
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
					  $(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/array.lib.sh
	$(INSTALL_BIN) -t $(1)/usr/lib/ripe-atlas/scripts \
					  $(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/atlas_log.lib.sh
	$(INSTALL_BIN) -t $(1)/usr/lib/ripe-atlas/scripts \
					  $(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/class.lib.sh
	$(INSTALL_BIN) -t $(1)/usr/lib/ripe-atlas/scripts \
					  $(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/common-pre.sh
	$(INSTALL_BIN) -t $(1)/usr/lib/ripe-atlas/scripts \
					  $(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/common.sh
	$(INSTALL_BIN) -t $(1)/usr/lib/ripe-atlas/scripts \
					  $(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/config.sh
	$(INSTALL_BIN) -t $(1)/usr/lib/ripe-atlas/scripts \
					  $(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/generic-ATLAS.sh
	$(INSTALL_BIN) -t $(1)/usr/lib/ripe-atlas/scripts \
					  $(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/generic-common.sh
	$(INSTALL_BIN) -t $(1)/usr/lib/ripe-atlas/scripts \
					  $(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/generic-reginit.sh
	$(INSTALL_BIN) -t $(1)/usr/lib/ripe-atlas/scripts \
					  $(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/json.lib.sh
	$(INSTALL_BIN) -t $(1)/usr/lib/ripe-atlas/scripts \
					  $(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/linux-functions.sh
	$(INSTALL_BIN) -t $(1)/usr/lib/ripe-atlas/scripts \
					  $(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/paths.lib.sh
	$(INSTALL_BIN) -t $(1)/usr/lib/ripe-atlas/scripts \
					  $(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/reg_servers.sh.dev
	$(INSTALL_BIN) -t $(1)/usr/lib/ripe-atlas/scripts \
					  $(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/reg_servers.sh.test
	$(INSTALL_BIN) -t $(1)/usr/lib/ripe-atlas/scripts \
					  $(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/reginit.sh
	$(INSTALL_BIN) -t $(1)/usr/lib/ripe-atlas/scripts \
					  $(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/resolvconf
	$(INSTALL_BIN) -t $(1)/usr/lib/ripe-atlas/scripts \
					  $(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/support.lib.sh

	$(INSTALL_DIR) $(1)/usr/share/ripe-atlas
	$(INSTALL_DATA) ./files/capabilities.json $(1)/usr/share/ripe-atlas/capabilities.json
	$(INSTALL_DATA) -t $(1)/usr/share/ripe-atlas $(PKG_INSTALL_DIR)/usr/share/ripe-atlas/FIRMWARE_APPS_VERSION
	$(INSTALL_DATA) -t $(1)/usr/share/ripe-atlas $(PKG_INSTALL_DIR)/usr/share/ripe-atlas/measurement.conf

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ripe-atlas $(1)/usr/sbin/ripe-atlas
	

endef

define Package/ripe-atlas-probe
	$(call Package/ripe-atlas/Default)
	TITLE+=(Software Probe)
	DEPENDS+=+ripe-atlas-common
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
	PROVIDES+=ripe-atlas-probe
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