#
# Copyright (C) 2007-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ahcpd
PKG_VERSION:=0.53
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.pps.univ-paris-diderot.fr/~jch/software/files/
PKG_MD5SUM:=a1a610bf20965aa522cd766bf3d5829a
PKG_LICENSE:=MIT


include $(INCLUDE_DIR)/package.mk

define Package/ahcpd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Ad-Hoc Configuration Protocol daemon
  URL:=http://www.pps.univ-paris-diderot.fr/~jch/software/ahcp/
  MAINTAINER:=Gabriel Kerneis <gabriel@kerneis.info>
  DEPENDS:=@IPV6 +ip +librt
endef

define Package/ahcpd/description
 Ahcpd is a daemon for configuring an IPv6 network using the Ad-Hoc
 Configuration Protocol (AHCP).  AHCP is designed for wireless mesh
 networks, where IPv6 autoconfiguration and DHCPv6 do not work, but may
 also be used on wired networks.
endef

define Package/ahcpd/conffiles
/etc/config/ahcpd
endef

MAKE_FLAGS += \
	      EXTRA_DEFINES="$(TARGET_CFLAGS)"

define Package/ahcpd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/ahcp
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ahcp-config.sh $(1)/etc/ahcp/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ahcpd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/ahcpd.config $(1)/etc/config/ahcpd
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ahcpd.init $(1)/etc/init.d/ahcpd
endef

$(eval $(call BuildPackage,ahcpd))
