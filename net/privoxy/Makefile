#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=privoxy
PKG_VERSION:=3.0.23
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-stable-src.tar.gz
PKG_SOURCE_URL:=@SF/ijbswa
PKG_MD5SUM:=bbe47d5ff1a54d9f9fc93a160532697f
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-stable
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=christian.schoenebeck@gmail.com

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  DEPENDS:=+libpcre +libpthread +zlib
  TITLE:=Privoxy WEB Proxy
  URL:=http://www.privoxy.org/
  USERID:=privoxy=8118:privoxy=8118
endef

# shown in LuCI package description
define Package/$(PKG_NAME)/description
$(TITLE) - Homepage: www.privoxy.org
endef

# shown in make menuconfig <Help>
define Package/$(PKG_NAME)/config
help
	Privoxy is a web proxy with advanced filtering capabilities for protecting
	privacy, modifying web page content, managing cookies, controlling access,
	and removing ads, banners, pop-ups and other obnoxious Internet junk. 
	Privoxy has a very flexible configuration and can be customized to suit
	individual needs and tastes. 
	Privoxy has application for both stand-alone systems and multi-user networks.

	Run as : $(USERID)
	Version: $(PKG_VERSION)-$(PKG_RELEASE)
	Home   : $(URL)

	$(PKG_MAINTAINER)
endef

CONFIGURE_ARGS += \
	--sysconfdir=/etc/privoxy

# needed otherwise errors during compile
MAKE_FLAGS:=

define Build/Install
	$(call Build/Install/Default,)
	# rename original sample config from pkg_source to save existing one during install
	mv $(PKG_INSTALL_DIR)/etc/privoxy/config $(PKG_INSTALL_DIR)/etc/privoxy/config.privoxy
endef

# "/etc/privoxy/config" temporary needed if updating from old version
define Package/$(PKG_NAME)/conffiles
/etc/config/privoxy
/etc/privoxy/config
endef

define Package/$(PKG_NAME)/preinst
	#!/bin/sh
	# if run within buildroot exit
	[ -n "$${IPKG_INSTROOT}" ] && exit 0
	# stop service if PKG_UPGRADE
	[ "$${PKG_UPGRADE}" = "1" ] && /etc/init.d/privoxy stop >/dev/null 2>&1
	exit 0	# supress errors from stop command
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/privoxy $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/privoxy.init $(1)/etc/init.d/privoxy
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/privoxy.hotplug $(1)/etc/hotplug.d/iface/80-privoxy

	$(INSTALL_DIR) $(1)/etc/privoxy
	$(CP) $(PKG_INSTALL_DIR)/etc/privoxy/* $(1)/etc/privoxy/
	# temporary needed if updating from old version
	# otherwise old config file will be delete by opkg
	$(INSTALL_CONF) ./files/privoxy.oldconfig $(1)/etc/privoxy/config
	# create .old file to be removed with next pacakge builds during update
	$(INSTALL_CONF) ./files/privoxy.oldconfig $(1)/etc/privoxy/config.old
	# copy NEW config
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/privoxy.config $(1)/etc/config/privoxy
endef

define Package/$(PKG_NAME)/postinst
	#!/bin/sh

	# if fresh install we don't need old config file in privoxy directory
	[ "$${PKG_UPGRADE}" = "0" ] && rm -f /etc/privoxy/config

	# if run within buildroot exit here
	[ -n "$${IPKG_INSTROOT}" ] && exit 0

	# if PKG_UPGRADE then build uci configuration
	# from existing(?) old /etc/privoxy/config file
	if [ "$${PKG_UPGRADE}" = "1" -a -f /etc/privoxy/config ]; then

		echo "converting OLD config to NEW uci configuration"

		SECTION="privoxy.privoxy"
		CFGFILE=/etc/privoxy/config

		echo -n > /etc/config/privoxy		# clear/create uci configuration file
		cp -f $${CFGFILE} $${CFGFILE}.old	# save old configuration

		# cleanup
		sed -i 's/^[ \t]*//;s/[ \t]*$$//' $${CFGFILE}	# remove invisible chars at beginning and end of lines
		sed -i '/^#/d' $${CFGFILE}			# remove lines with "#"
		sed -i '/^$$/d' $${CFGFILE}			# remove empty lines

		uci -q set $${SECTION}="privoxy"		# create section

		cat $${CFGFILE} | while read LINE; do
			# option is first parameter; uci did not like "-" in option names
			OPT=$$(echo $${LINE} | awk '{print $$1}' | sed 's/-/_/g')
			VAL=$$(echo $${LINE} | awk '{print $$2}')
			case $${OPT} in
				# debug 1024 => debug_1024 '1'
				debug)
					uci -q set $${SECTION}.debug_$${VAL}="1"
					;;
				# handle list values; splitted case for better reading
				actionsfile|filterfile|listen_address)
					uci -q add_list $${SECTION}.$${OPT}="$${VAL}"
					;;
				permit_access|deny_access)
					uci -q add_list $${SECTION}.$${OPT}="$${VAL}"
					;;
				trust_info_url|forward)
					uci -q add_list $${SECTION}.$${OPT}="$${VAL}"
					;;
				forward_socks4|forward_socks4a)
					uci -q add_list $${SECTION}.$${OPT}="$${VAL}"
					;;
				forward_socks5|forward_socks5t)
					uci -q add_list $${SECTION}.$${OPT}="$${VAL}"
					;;
				# all others are normal options
				*)
					uci -q set $${SECTION}.$${OPT}="$${VAL}"
					;;
			esac
		done
		uci -q commit privoxy	# commit changes
		rm -f $${CFGFILE}	# remove old configuration file
	fi

	# set permissions to privoxy group
	echo "setting permissions"
	chgrp -R privoxy /etc/privoxy/*
	chmod 664 /etc/privoxy/*
	chmod 755 /etc/privoxy/templates
	chmod 644 /etc/privoxy/templates/*
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
