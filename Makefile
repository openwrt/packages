# 
# Copyright (C) 2007-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ndppd
PKG_VERSION:=0.2.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.priv.nu/projects/ndppd/files/
PKG_MD5SUM:=9b65a8cccfce8689f0c1c410c20b4790

include $(INCLUDE_DIR)/package.mk

define Package/ndppd
  SECTION:=ipv6
  CATEGORY:=IPv6
  TITLE:=NDP Proxy Daemon
  URL:=http://www.priv.nu/projects/ndppd/
  MAINTAINER:=Gabriel Kerneis <kerneis@pps.jussieu.fr>
  DEPENDS:=+kmod-ipv6 +confuse +uclibcxx
endef

define Package/ndppd/description
 ndppd, or NDP Proxy Daemon, is a daemon that proxies NDP (Neighbor Discovery
 Protocol) messages between interfaces.  ndppd currently only supports Neighbor
 Solicitation Messages and Neighbor Advertisement Messages.

 The ndp_proxy provided by Linux doesn't support listing proxies, and only hosts
 are supported.  No subnets.  ndppd solves this by listening for Neighbor
 Solicitation messages on an interface, then query the internal interfaces for
 that target IP before finally sending a Neighbor Advertisement message.
endef

define Package/ndppd/conffiles
/etc/ndppd.conf
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CXX="$(TARGET_CXX)" \
		CXXFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CXXFLAGS) -fno-builtin -fno-rtti -nostdinc++ \
			-I$(STAGING_DIR)/usr/include/uClibc++ -I$(LINUX_DIR)/include" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		LIBS="-nodefaultlibs -lc -luClibc++ -lconfuse" \
		ndppd
endef

define Package/ndppd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ndppd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ndppd.init $(1)/etc/init.d/ndppd
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/ndppd.conf-dist $(1)/etc/ndppd.conf
endef

$(eval $(call BuildPackage,ndppd))
