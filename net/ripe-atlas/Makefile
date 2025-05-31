include $(TOPDIR)/rules.mk

PKG_NAME:=ripe-atlas
PKG_VERSION:=5110
PKG_RELEASE:=1

PKG_LICENSE:=GPL
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tiago Gaspar <tiagogaspar8@gmail.com>, Michel Stam <mstam@ripe.net>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/RIPE-NCC/ripe-atlas-software-probe.git

PKG_MIRROR_HASH:=abd738c1b607edcb50b81518dee73f60a1e86b04e5e76382015d6df7a09a517a
PKG_SOURCE_VERSION:=93adf79ca203734cd531a25a1ada060f3fb7b535

PKG_FIXUP=autoreconf
PKG_INSTALL:=1
PRB_TYPE:=generic

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
	--with-probe-type=$(PRB_TYPE) \
	--with-user=root \
	--with-group=ripe-atlas \
	--with-measurement-user=root \
	--disable-systemd \
	--disable-setcap-install \
	--disable-chown


define Package/ripe-atlas-common
	$(call Package/ripe-atlas/Default)
	TITLE+=(common files)
	USERID:=$(ATLAS_USER):$(ATLAS_GROUP) $(ATLAS_MEAS):$(ATLAS_GROUP)
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
	CONFLICTS:=atlas-sw-probe \
	           atlas-sw-probe-rpc
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
	$(INSTALL_DIR) \
		$(1)/etc/init.d \
		$(1)/etc/config \
		$(1)/etc/ripe-atlas \
		$(1)/usr/lib/ripe-atlas/measurement \
		$(1)/usr/lib/ripe-atlas/scripts \
		$(1)/usr/share/ripe-atlas \
		$(1)/usr/sbin
	$(INSTALL_BIN) -t \
		$(1)/usr/lib/ripe-atlas/scripts \
		$(foreach script, \
			array.lib.sh \
			atlas_log.lib.sh \
			class.lib.sh \
			common-pre.sh \
			common.sh \
			config.sh \
			$(PRB_TYPE)-ATLAS.sh \
			$(PRB_TYPE)-common.sh \
			$(PRB_TYPE)-reginit.sh \
			json.lib.sh \
			linux-functions.sh \
			paths.lib.sh \
			reg_servers.sh.dev \
			reg_servers.sh.test \
			reginit.sh \
			resolvconf \
			support.lib.sh, \
			$(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/scripts/$(script))
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/measurement/busybox \
		$(1)/usr/lib/ripe-atlas/measurement/busybox
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/sbin/ripe-atlas \
		$(1)/usr/sbin/ripe-atlas
	$(INSTALL_DATA) -t \
		$(1)/usr/share/ripe-atlas \
		$(foreach file, \
			FIRMWARE_APPS_VERSION \
			measurement.conf, \
			$(PKG_INSTALL_DIR)/usr/share/ripe-atlas/$(file))
	$(INSTALL_BIN) files/ripe-atlas.init $(1)/etc/init.d/ripe-atlas
	$(INSTALL_CONF) files/ripe-atlas.conf $(1)/etc/config/ripe-atlas
	$(INSTALL_DATA) files/capabilities.json $(1)/usr/share/ripe-atlas/capabilities.json
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
	$(INSTALL_DIR) \
		$(1)/usr/lib/ripe-atlas/scripts \
		$(1)/usr/share/ripe-atlas
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/config/probe/known_hosts.reg \
		$(1)/usr/share/ripe-atlas
	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/config/probe/reg_servers.sh.prod \
		$(1)/usr/lib/ripe-atlas/scripts
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
	$(INSTALL_DIR) \
		$(1)/usr/lib/ripe-atlas/scripts \
		$(1)/usr/share/ripe-atlas
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/config/anchor/known_hosts.reg \
		$(1)/usr/share/ripe-atlas
	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/config/anchor/reg_servers.sh.prod \
		$(1)/usr/lib/ripe-atlas/scripts
endef

$(eval $(call BuildPackage,ripe-atlas-common))
$(eval $(call BuildPackage,ripe-atlas-anchor))
$(eval $(call BuildPackage,ripe-atlas-probe))