#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=keepalived
PKG_VERSION:=2.2.8
PKG_RELEASE:=7

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.keepalived.org/software
PKG_HASH:=85882eb62974f395d4c631be990a41a839594a7e62fbfebcb5649a937a7a1bb6

PKG_CPE_ID:=cpe:/a:keepalived:keepalived
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Ben Kelly <ben@benjii.net> \
		Florian Eckert <fe@dev.tdt.de>

PKG_CONFIG_DEPENDS:= \
	CONFIG_KEEPALIVED_NFTABLES \
	CONFIG_KEEPALIVED_VRRP \
	CONFIG_KEEPALIVED_LVS \
	CONFIG_KEEPALIVED_IPTABLES \
	CONFIG_KEEPALIVED_BFD \
	CONFIG_KEEPALIVED_SNMP_VRRP \
	CONFIG_KEEPALIVED_SNMP_CHECKER \
	CONFIG_KEEPALIVED_SNMP_RFC2 \
	CONFIG_KEEPALIVED_SNMP_RFC3 \
	CONFIG_KEEPALIVED_SNMP_REPLY_V3_FOR_V2 \
	CONFIG_KEEPALIVED_DBUS \
	CONFIG_KEEPALIVED_ROUTES \
	CONFIG_IPV6

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/keepalived/config
	source "$(SOURCE)/Config.in"
endef

# The +kmod-nf-ipvs line should be +KEEPALIVED_LVS:kmod-nf-ipvs,
# but make menuconfig then reports :error: recursive dependency detected!
# !!FIXME DEPENDS:= +KEEPALIVED_LVS:kmod-nf-ipvs
define Package/keepalived
  SECTION:=net
  CATEGORY:=Network
  TITLE:=VRRP with failover and monitoring daemon for LVS clusters
  URL:=http://www.keepalived.org/
  DEPENDS:= \
    +libnl-genl \
    +libmagic \
    +libkmod \
    +kmod-nf-ipvs \
    +libjson-c \
    +KEEPALIVED_NFTABLES:libnftnl \
    +KEEPALIVED_VRRP:kmod-macvlan \
    +KEEPALIVED_VRRP:libnl-route \
    +KEEPALIVED_VRRP:libnfnetlink \
    +KEEPALIVED_SHA1:libopenssl \
    +KEEPALIVED_IPTABLES:libip4tc \
    +KEEPALIVED_IP6TABLES:libip6tc \
    +KEEPALIVED_IPTABLES:libxtables \
    +KEEPALIVED_IPTABLES:libipset \
    +(KEEPALIVED_SNMP_VRRP||KEEPALIVED_SNMP_CHECKER||KEEPALIVED_SNMP_RFC2||KEEPALIVED_SNMP_RFC3):libnetsnmp \
    +KEEPALIVED_DBUS:glib2
endef

define Package/keepalived/description
 VRRP with failover and monitoring daemon for Linux Virtual Server (LVS) clusters.
endef

define Package/keepalived/conffiles
/etc/keepalived/keepalived.conf
/etc/config/keepalived
/etc/keepalived.user
endef

CONFIGURE_ARGS+= \
	--enable-json \
	--with-init=SYSV \
	--disable-track-process \
	--runstatedir="/var/run"

ifeq ($(CONFIG_KEEPALIVED_VRRP),)
CONFIGURE_ARGS += \
	--disable-vrrp
endif

ifeq ($(CONFIG_KEEPALIVED_LVS),)
CONFIGURE_ARGS += \
	--disable-lvs
endif

ifeq ($(CONFIG_KEEPALIVED_BFD),y)
CONFIGURE_ARGS += \
	--enable-bfd
endif

ifeq ($(CONFIG_KEEPALIVED_SHA1),y)
CONFIGURE_ARGS += \
	--enable-sha1
endif


ifeq ($(CONFIG_KEEPALIVED_VRRP),y)

ifeq ($(CONFIG_KEEPALIVED_NFTABLES),)
CONFIGURE_ARGS += \
	--disable-nftables
endif

ifeq ($(CONFIG_KEEPALIVED_IPTABLES),)
CONFIGURE_ARGS += \
	--disable-iptables
endif

ifeq ($(CONFIG_KEEPALIVED_IPSETS),)
CONFIGURE_ARGS += \
	--disable-libipset-dynamic
endif

ifeq ($(CONFIG_KEEPALIVED_SNMP_VRRP),y)
CONFIGURE_ARGS += \
	--enable-snmp-vrrp
endif

ifeq ($(CONFIG_KEEPALIVED_SNMP_RFC2),y)
CONFIGURE_ARGS += \
	--enable-snmp-rfcv2
endif

ifeq ($(CONFIG_KEEPALIVED_SNMP_RFC3),y)
CONFIGURE_ARGS += \
	--enable-snmp-rfcv3
endif

ifeq ($(CONFIG_KEEPALIVED_SNMP_RFC3),y)
ifeq ($(CONFIG_KEEPALIVED_SNMP_REPLY_V3_FOR_V2),)
CONFIGURE_ARGS += \
	--disable-snmp-reply-v3-for-v2
endif
endif # CONFIG_KEEPALIVED_SNMP_RFC3

ifeq ($(CONFIG_KEEPALIVED_VRRP_AUTH),)
CONFIGURE_ARGS += \
	--disable-vrrp-auth
endif

ifeq ($(CONFIG_KEEPALIVED_CHECKSUM_COMPAT),)
CONFIGURE_ARGS += \
	--disable-checksum-compat
endif

ifeq ($(CONFIG_KEEPALIVED_DBUS),y)
CONFIGURE_ARGS += \
	--enable-dbus
endif

ifeq ($(CONFIG_KEEPALIVED_LINKBEAT),)
CONFIGURE_ARGS += \
	--disable-linkbeat
endif

ifeq ($(CONFIG_KEEPALIVED_ROUTES),)
CONFIGURE_ARGS += \
	--disable-routes
endif
endif # CONFIG_KEEPALIVED_VRRP


ifeq ($(CONFIG_KEEPALIVED_LVS),y)
ifeq ($(CONFIG_KEEPALIVED_LVS_SYNCD),)
CONFIGURE_ARGS += \
	--disable-lvs-syncd
endif

ifeq ($(CONFIG_KEEPALIVED_LVS_64BIT_STATS),)
CONFIGURE_ARGS += \
	--disable-lvs-64bit-stats
endif

ifeq ($(CONFIG_KEEPALIVED_FWMARK),)
CONFIGURE_ARGS += \
	--disable-fwmark
endif

ifeq ($(CONFIG_KEEPALIVED_SNMP_CHECKER),y)
CONFIGURE_ARGS += \
	--enable-snmp-checker
endif

endif # CONFIG_KEEPALIVED_LVS


MAKE_FLAGS += STRIP="/bin/true"
TARGET_CFLAGS += -I$(LINUX_DIR)

define Package/keepalived/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/keepalived \
		$(1)/usr/sbin/

ifeq ($(CONFIG_KEEPALIVED_LVS),y)
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/genhash \
		$(1)/usr/bin/
endif

	$(INSTALL_DIR) $(1)/etc/keepalived
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/keepalived/keepalived.conf.sample \
		$(1)/etc/keepalived/keepalived.conf

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/keepalived \
		$(1)/etc/uci-defaults/keepalived

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/keepalived.init \
		$(1)/etc/init.d/keepalived

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/keepalived.config \
		$(1)/etc/config/keepalived

	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/keepalived.user \
		$(1)/etc/keepalived.user

	$(INSTALL_DIR) $(1)/etc/hotplug.d/keepalived
	$(INSTALL_DATA) ./files/hotplug-user \
		$(1)/etc/hotplug.d/keepalived/01-user

	$(INSTALL_DIR) $(1)/usr/libexec/rpcd
	$(INSTALL_BIN) ./files/usr/libexec/rpcd/keepalived \
		$(1)/usr/libexec/rpcd/keepalived

ifneq ($(CONFIG_KEEPALIVED_SNMP_VRRP)$(CONFIG_KEEPALIVED_SNMP_CHECKER)$(CONFIG_KEEPALIVED_SNMP_RFC2)$(CONFIG_KEEPALIVED_SNMP_RFC3),)
	$(INSTALL_DIR) $(1)/usr/share/snmp/mibs
endif

ifneq ($(CONFIG_KEEPALIVED_SNMP_VRRP)$(CONFIG_KEEPALIVED_SNMP_CHECKER),)
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/snmp/mibs/KEEPALIVED-MIB.txt \
		$(1)/usr/share/snmp/mibs/KEEPALIVED-MIB.txt
endif

ifeq ($(CONFIG_KEEPALIVED_SNMP_RFC2),y)
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/snmp/mibs/VRRP-MIB.txt \
		$(1)/usr/share/snmp/mibs/VRRP-MIB.txt
endif

ifeq ($(CONFIG_KEEPALIVED_SNMP_RFC3),y)
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/snmp/mibs/VRRPv3-MIB.txt \
		$(1)/usr/share/snmp/mibs/VRRPv3-MIB.txt
endif

ifeq ($(CONFIG_KEEPALIVED_DBUS),y)
	$(INSTALL_DIR) $(1)/etc/dbus-1/system.d
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/dbus-1/system.d/org.keepalived.Vrrp1.conf \
		$(1)/etc/dbus-1/system.d/org.keepalived.Vrrp1.conf

	$(INSTALL_DIR) $(1)/usr/share/dbus-1/interfaces
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/dbus-1/interfaces/org.keepalived.Vrrp1.Instance.xml \
		$(1)/usr/share/dbus-1/interfaces/org.keepalived.Vrrp1.Instance.xml
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/dbus-1/interfaces/org.keepalived.Vrrp1.Vrrp.xml \
		$(1)/usr/share/dbus-1/interfaces/org.keepalived.Vrrp1.Vrrp.xml
endif

endef

define Package/keepalived-sync
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Keepalived Master and Backup Synchronization
  DEPENDS:= +keepalived +rsync +inotifywait +sudo +coreutils-timeout
endef

define Package/keepalived-sync/description
 Keepalived HA with Master to Backup files and data Synchronization
endef

define Package/keepalived-sync/conffiles
/etc/keepalived/scripts
/etc/keepalived/keys
endef

define Package/keepalived-sync/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/keepalived-inotify \
		$(1)/etc/init.d/keepalived-inotify

	$(INSTALL_DIR) $(1)/usr/share/keepalived/scripts
	$(INSTALL_BIN) ./files/usr/share/keepalived/scripts/rsync.sh \
		$(1)/usr/share/keepalived/scripts/rsync.sh

	$(INSTALL_DIR) $(1)/etc/keepalived/scripts
	$(LN) /usr/share/keepalived/scripts/rsync.sh \
		$(1)/etc/keepalived/scripts/rsync.sh

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/keepalived-rsync-inotify \
		$(1)/usr/bin/keepalived-rsync-inotify

	$(INSTALL_DIR) $(1)/lib/functions/keepalived
	$(INSTALL_DATA) ./files/lib/functions/keepalived/hotplug.sh \
		$(1)/lib/functions/keepalived/hotplug.sh
	$(INSTALL_DATA) ./files/lib/functions/keepalived/common.sh \
		$(1)/lib/functions/keepalived/common.sh

	$(INSTALL_DIR) $(1)/usr/libexec/keepalived/rpc
	$(INSTALL_DATA) ./files/usr/libexec/keepalived/rpc/sync.sh \
		$(1)/usr/libexec/keepalived/rpc/sync.sh

	$(INSTALL_DIR) $(1)/etc/hotplug.d/keepalived
	$(CP) ./files/etc/hotplug.d/keepalived/* \
		$(1)/etc/hotplug.d/keepalived
endef

USER=keepalived
USER_ID=60001
USER_HOME=/usr/share/keepalived/rsync
SUDO_DIR=/etc/sudoers.d
SUDO_FILE=$(SUDO_DIR)/$(USER)
KEYS_DIR=/etc/keepalived/keys

define Package/keepalived-sync/postinst
	#!/bin/sh

	mkdir -p "$${IPKG_INSTROOT}/etc/uci-defaults"
	DEFAULT_SCRIPT="$${IPKG_INSTROOT}/etc/uci-defaults/99-keepalived-sync"

	cat << EOF > $${DEFAULT_SCRIPT}
#!/bin/sh

. /lib/functions.sh

mkdir -p $(KEYS_DIR)

group_add "$(USER)" "$(USER_ID)"
user_add "$(USER)" "$(USER_ID)" "$(USER_ID)" "$(USER)" "$(USER_HOME)" "/bin/ash"

mkdir -m 700 -p "$(USER_HOME)"
mkdir -m 700 -p "$(USER_HOME)/.ssh"
chown "$(USER)":"$(USER)" "$(USER_HOME)" -R

[ ! -d "$(SUDO_DIR)" ] && mkdir "$(SUDO_DIR)"
echo "$(USER) ALL= NOPASSWD:/usr/bin/rsync" > "$(SUDO_FILE)"
EOF

	[ -z "$${IPKG_INSTROOT}" ] && [ -f "$${DEFAULT_SCRIPT}" ] && sh "$${DEFAULT_SCRIPT}"

	exit 0
endef

define Package/keepalived-sync/postrm
	#!/bin/sh

	[ -n "$${IPKG_INSTROOT}" ] && exit 0

	[ -d "$(KEYS_DIR)" ] && rm -rf "$(KEYS_DIR)"
	[ -d "$(USER_HOME)" ] && rm -rf "$(USER_HOME)"
	[ -f "$(SUDO_FILE)" ] && rm -f "$(SUDO_FILE)"

	sed -i -e "/^$(USER):/d" /etc/passwd /etc/shadow /etc/group

	exit 0
endef

$(eval $(call BuildPackage,keepalived))
$(eval $(call BuildPackage,keepalived-sync))
