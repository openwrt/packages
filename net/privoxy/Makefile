#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=privoxy
PKG_VERSION:=3.0.23
PKG_RELEASE:=3

PKG_SOURCE:=privoxy-$(PKG_VERSION)-stable-src.tar.gz
PKG_SOURCE_URL:=@SF/ijbswa
PKG_MD5SUM:=bbe47d5ff1a54d9f9fc93a160532697f
PKG_BUILD_DIR:=$(BUILD_DIR)/privoxy-$(PKG_VERSION)-stable
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

define Package/$(PKG_NAME)/conffiles
/etc/config/privoxy
/etc/privoxy/user.action
/etc/privoxy/user.filter
/etc/privoxy/user.trust
endef

define Package/$(PKG_NAME)/preinst
	#!/bin/sh
	[ -n "$${IPKG_INSTROOT}" ] && exit 0	# if run within buildroot exit

	# stop service if PKG_UPGRADE
	[ "$${PKG_UPGRADE}" = "1" ] && /etc/init.d/privoxy stop >/dev/null 2>&1
		
	exit 0	# supress errors from stop command
endef

define Package/$(PKG_NAME)/install
	if [ -f $(PKG_INSTALL_DIR)/etc/privoxy/trust ]; then \
		mv -f $(PKG_INSTALL_DIR)/etc/privoxy/trust $(PKG_INSTALL_DIR)/etc/privoxy/user.trust; \
	fi
	if [ -f $(PKG_INSTALL_DIR)/etc/privoxy/config ]; then \
		rm -f $(PKG_INSTALL_DIR)/etc/privoxy/config; \
	fi

	$(INSTALL_DIR) \
		$(1)/usr/sbin\
		$(1)/etc/privoxy/templates
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/privoxy $(1)/usr/sbin/
	find $(PKG_INSTALL_DIR)/etc/privoxy/templates -maxdepth 1 -type f \
		-exec $(INSTALL_DATA) -t $(1)/etc/privoxy/templates {} \;
	find $(PKG_INSTALL_DIR)/etc/privoxy -maxdepth 1 -type f \
		-exec install -m0664 -t $(1)/etc/privoxy {} \;

	$(INSTALL_DIR) \
		$(1)/etc/init.d \
		$(1)/etc/hotplug.d/iface \
		$(1)/etc/config
	$(INSTALL_BIN)  ./files/privoxy.init $(1)/etc/init.d/privoxy
	$(INSTALL_BIN)  ./files/privoxy.hotplug $(1)/etc/hotplug.d/iface/80-privoxy
	$(INSTALL_CONF) ./files/privoxy.config $(1)/etc/config/privoxy
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
