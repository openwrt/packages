#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ripe-atlas
PKG_VERSION:=5130
PKG_RELEASE:=3

PKG_SOURCE:=ripe-atlas-software-probe-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/RIPE-NCC/ripe-atlas-software-probe/tar.gz/refs/tags/$(PKG_VERSION)?
PKG_HASH:=d2b0b03c1c27b9e1cfc8329c4862141ca53d0f46f8cb36af92a3adc2e5d26ff6
PKG_BUILD_DIR:=$(BUILD_DIR)/ripe-atlas-software-probe-$(PKG_VERSION)

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=GPL-3.0-only GPL-2.0-only LGPL-2.1-or-later BSD-3-Clause ISC
PKG_LICENSE_FILES:=LICENSE probe-busybox/LICENSE \
	probe-busybox/libevent-2.1.11-stable/LICENSE

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

# Restore busybox's compiler-driver LD; OpenWrt overrides it with raw ld.bfd.
MAKE_FLAGS += LD="$(TARGET_CC) -nostdlib"

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

# The init in ripe-atlas-common waits for the variant, and apk installs the
# variant only after it started the service.
define Package/ripe-atlas/Default/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || ! /etc/init.d/ripe-atlas enabled ||
	/etc/init.d/ripe-atlas restart
exit 0
endef

# The measurement applets need raw sockets. With procd-ujail installed the
# probe runs as ripe-atlas and ujail hands it CAP_NET_RAW from
# capabilities.json; without ujail the init falls back to root, as
# atlas-sw-probe always ran, because procd grants capabilities only via ujail.
CONFIGURE_ARGS+= \
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
	+openssh-client \
	+openssh-keygen \
	+libopenssl \
	+@OPENSSL_WITH_DEPRECATED \
	+@BUSYBOX_CONFIG_KILL \
	+@BUSYBOX_CONFIG_SED \
	+@BUSYBOX_CONFIG_TEE \
	+@BUSYBOX_CONFIG_CMP \
	+@BUSYBOX_CONFIG_FIND \
	+@BUSYBOX_CONFIG_FEATURE_FIND_MAXDEPTH \
	+@BUSYBOX_CONFIG_FEATURE_FIND_TYPE \
	+@BUSYBOX_CONFIG_FEATURE_FIND_USER \
	+@BUSYBOX_CONFIG_FEATURE_FIND_GROUP \
	+@BUSYBOX_CONFIG_FEATURE_FIND_NOT
endef

define Package/ripe-atlas-common/conffiles
/etc/ripe-atlas/probe_key
/etc/ripe-atlas/probe_key.pub
/etc/config/ripe-atlas
endef

define Package/ripe-atlas-common/description
  RIPE Atlas (common files)

  $(call Package/ripe-atlas/Default/description)
endef

RIPE_ATLAS_APPLETS:= \
	atlasinit buddyinfo condmv date dfrm eooqd eperd evhttpget evntp \
	evping evsslgetcert evtdig evtraceroute httppost onlyuptime perd \
	rchoose rptaddrs rptra6 rptuptime rxtxrpt telnetd

define Package/ripe-atlas-common/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ripe-atlas.init $(1)/etc/init.d/ripe-atlas

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/ripe-atlas.conf $(1)/etc/config/ripe-atlas

	$(INSTALL_DIR) $(1)/etc/ripe-atlas

	$(INSTALL_DIR) $(1)/usr/lib/ripe-atlas/measurement
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/ripe-atlas/measurement/busybox \
		       $(1)/usr/lib/ripe-atlas/measurement/busybox
	$(foreach applet,$(RIPE_ATLAS_APPLETS), \
		$(LN) busybox $(1)/usr/lib/ripe-atlas/measurement/$(applet);)

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
	$(INSTALL_DATA) -t $(1)/usr/share/ripe-atlas \
		$(PKG_INSTALL_DIR)/usr/share/ripe-atlas/measurement.conf

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ripe-atlas $(1)/usr/sbin/ripe-atlas
endef

define Package/ripe-atlas-probe
  $(call Package/ripe-atlas/Default)
  TITLE+=(Software Probe)
  DEPENDS+=+ripe-atlas-common
  PROVIDES:=ripe-atlas atlas-sw-probe
  DEFAULT_VARIANT:=1
  CONFLICTS:=ripe-atlas-anchor
endef

define Package/ripe-atlas-probe/description
  RIPE Atlas (Software Probe)

  $(call Package/ripe-atlas/Default/description)
endef

define Package/ripe-atlas-probe/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/ripe-atlas.defaults \
		       $(1)/etc/uci-defaults/80-ripe-atlas

	$(INSTALL_DIR) $(1)/usr/lib/ripe-atlas/scripts
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/config/probe/reg_servers.sh.prod \
		$(1)/usr/lib/ripe-atlas/scripts

	$(INSTALL_DIR) $(1)/usr/share/ripe-atlas
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/config/probe/known_hosts.reg \
		$(1)/usr/share/ripe-atlas
	echo probe > $(1)/usr/share/ripe-atlas/variant
endef

Package/ripe-atlas-probe/postinst = $(Package/ripe-atlas/Default/postinst)

define Package/ripe-atlas-anchor
  $(call Package/ripe-atlas/Default)
  TITLE+=(Anchor)
  DEPENDS+=+ripe-atlas-common
  PROVIDES:=ripe-atlas
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
	echo anchor > $(1)/usr/share/ripe-atlas/variant
endef

Package/ripe-atlas-anchor/postinst = $(Package/ripe-atlas/Default/postinst)

$(eval $(call BuildPackage,ripe-atlas-common))
$(eval $(call BuildPackage,ripe-atlas-anchor))
$(eval $(call BuildPackage,ripe-atlas-probe))
