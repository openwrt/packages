#
# Copyright (C) 2019 Banglang Huang <banglang.huang@foxmail.com>
# Copyright (C) 2019 Rosy Song <rosysong@rosinson.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=kea
PKG_VERSION:=3.0.2
PKG_RELEASE:=5

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://ftp.isc.org/isc/kea/$(PKG_VERSION)
PKG_HASH:=29f4e44fa48f62fe15158d17411e003496203250db7b3459c2c79c09f379a541

PKG_MAINTAINER:=Philip Prindeville <philipp@redfish-solutions.com>, Noah Meyerhans <frodo@morgul.net>
PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_FLAGS:=gc-sections

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/kea/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=ISC Kea
  URL:=https://www.isc.org/kea
endef

define Package/kea/conffiles
/etc/kea/
endef

Package/kea-ctrl/conffiles = $(Package/kea/conffiles)
Package/kea-dhcp4/conffiles = $(Package/kea/conffiles)
Package/kea-dhcp6/conffiles = $(Package/kea/conffiles)
Package/kea-dhcp-ddns/conffiles = $(Package/kea/conffiles)

###### *************************************************************************
define Package/kea
	$(call Package/kea/Default)
  TITLE+=ISC Kea
endef
# shown in LuCI package description
define Package/kea/description
  Kea is an open source DHCPv4/DHCPv6 server being developed by Internet
  Systems Consortium. Kea is a high-performance, extensible DHCP server
  engine that is designed to be easily modified and extended with hooks
  libraries. It provides DHCPv4 and DHCPv6 servers, a dynamic DNS update
  module, a portable DHCP library, libdhcp++, control agent that provides
  management REST interface, and a DHCP benchmarking tool, perfdhcp.
endef

###### *************************************************************************
define Package/kea-libs
	$(call Package/kea/Default)
	TITLE+=Libraries
	DEPENDS:=+libopenssl +log4cplus +boost
endef
define Package/kea-libs/description
		Kea required Libraries.
endef

###### *************************************************************************
define Package/kea-ctrl
	$(call Package/kea/Default)
	TITLE+=Control
	DEPENDS:=+procps-ng +procps-ng-ps +kea-dhcp4 \
	+IPV6:kea-dhcp6 +kea-dhcp-ddns
endef
define Package/kea-ctrl/description
	Tool to start, stop, reconfigure, and report status for the Kea servers.
endef

###### *************************************************************************
define Package/kea-dhcp4
	$(call Package/kea/Default)
	TITLE+=DHCP Server v4
	DEPENDS:=+kea-libs
endef
define Package/kea-dhcp4/description
    The DHCPv4 server process. This process responds to DHCPv4 queries from clients.
endef

###### *************************************************************************
define Package/kea-dhcp6
	$(call Package/kea/Default)
	TITLE+=DHCP Server v6
	DEPENDS:=@IPV6 +kea-libs
endef
define Package/kea-dhcp6/description
    The DHCPv6 server process. This process responds to DHCPv6 queries from clients.
endef

###### *************************************************************************
define Package/kea-dhcp-ddns
	$(call Package/kea/Default)
	TITLE+=DHCP Dynamic DNS
	DEPENDS:=+kea-libs
endef
define Package/kea-dhcp-ddns/description
		The DHCP Dynamic DNS process. This process acts as an intermediary between
the DHCP servers and DNS servers. It receives name update requests from the
DHCP servers and sends DNS Update messages to the DNS servers.
endef

###### *************************************************************************
define Package/kea-admin
	$(call Package/kea/Default)
	TITLE+=Admin
	DEPENDS:=+kea-libs
endef
define Package/kea-admin/description
   	A useful tool for database backend maintenance (creating a new database,
checking versions, upgrading etc.).
endef

###### *************************************************************************
define Package/kea-hook-ha
	$(call Package/kea/Default)
	TITLE+=High Availability hook library
	DEPENDS:=+kea-libs +kea-hook-lease-cmds
endef
define Package/kea-hook-ha/description
	The high availability hook library.
endef

###### *************************************************************************
define Package/kea-hook-lease-cmds
	$(call Package/kea/Default)
	TITLE+=Lease Commands hook library
	DEPENDS:=+kea-libs
endef
define Package/kea-hook-lease-cmds/description
	The lease commands hook library.
endef

##### *************************************************************************
define Package/kea-lfc
	$(call Package/kea/Default)
	TITLE+=lfc
	DEPENDS:=+kea-libs
endef
define Package/kea-lfc/description
    This process removes redundant information from the files used to provide
persistent storage for the memfile data base backend. While it can be run
standalone, it is normally run as and when required by the Kea DHCP servers.
endef

##### *************************************************************************
define Package/kea-perfdhcp
	$(call Package/kea/Default)
	TITLE+=perfdhcp (Benchmarking)
	DEPENDS:=+kea-libs
endef
define Package/kea-perfdhcp/description
     A DHCP benchmarking tool which simulates multiple clients to test both
DHCPv4 and DHCPv6 server performance.
endef

###### *************************************************************************
define Package/kea-shell
	$(call Package/kea/Default)
	TITLE+=shell
	DEPENDS:=+kea-libs
endef
define Package/kea-shell/description
     This simple text client uses the REST interface to connect to the Kea
Control Agent.
endef

###### *************************************************************************
define Package/kea-uci
	$(call Package/kea/Default)
	TITLE+=UCI support
	DEPENDS:=@(PACKAGE_kea-ctrl||PACKAGE_kea-dhcp4||PACKAGE_kea-dhcp6||PACKAGE_kea-dhcp-ddns)
endef
define Package/kea-uci/description
	Kea PROCD/UCI support. This package installs a UCI config file and
	a PROCD service file.
endef

###### *************************************************************************

MESON_ARGS += \
	-Dkrb5=disabled \
	-Dmysql=disabled \
	-Dnetconf=disabled \
	-Dpostgresql=disabled

define Package/kea-libs/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so.* $(1)/usr/lib/
endef

define Package/kea-dhcp4/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/kea
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/kea-dhcp4 $(1)/usr/sbin/kea-dhcp4
	$(CP) $(PKG_INSTALL_DIR)/etc/kea/kea-dhcp4.conf $(1)/etc/kea/
endef

define Package/kea-dhcp6/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/kea
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/kea-dhcp6 $(1)/usr/sbin/kea-dhcp6
	$(CP) $(PKG_INSTALL_DIR)/etc/kea/kea-dhcp6.conf $(1)/etc/kea/
endef

define Package/kea-dhcp-ddns/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/kea
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/kea-dhcp-ddns $(1)/usr/sbin/kea-dhcp-ddns
	$(CP) $(PKG_INSTALL_DIR)/etc/kea/kea-dhcp-ddns.conf $(1)/etc/kea/
endef

define Package/kea-admin/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/kea-admin $(1)/usr/sbin/kea-admin
endef

define Package/kea-hook-ha/install
	$(INSTALL_DIR) $(1)/usr/lib/kea/hooks
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/kea/hooks/libdhcp_ha.so $(1)/usr/lib/kea/hooks
endef

define Package/kea-hook-lease-cmds/install
	$(INSTALL_DIR) $(1)/usr/lib/kea/hooks
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/kea/hooks/libdhcp_lease_cmds.so $(1)/usr/lib/kea/hooks
endef

define Package/kea-ctrl/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/kea
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/keactrl $(1)/usr/sbin/keactrl
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/kea-ctrl-agent $(1)/usr/sbin/kea-ctrl-agent
	$(CP) $(PKG_INSTALL_DIR)/etc/kea/keactrl.conf $(1)/etc/kea/
	$(CP) $(PKG_INSTALL_DIR)/etc/kea/kea-ctrl-agent.conf $(1)/etc/kea/
endef

define Package/kea-lfc/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/kea-lfc $(1)/usr/sbin/kea-lfc
endef

define Package/kea-perfdhcp/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/perfdhcp $(1)/usr/sbin/perfdhcp
endef

define Package/kea-shell/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/kea-shell $(1)/usr/sbin/kea-shell
endef

define Package/kea-uci/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_CONF) ./files/kea.config $(1)/etc/config/kea
	$(INSTALL_BIN) ./files/kea.init $(1)/etc/init.d/kea
	$(INSTALL_DIR) $(1)/usr/lib/kea/importers
	$(INSTALL_BIN) ./files/dhcp4.sh $(1)/usr/lib/kea/importers/
endef

define Package/kea-uci/conffiles
/etc/config/kea
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,kea-libs))
$(eval $(call BuildPackage,kea-ctrl))
$(eval $(call BuildPackage,kea-dhcp4))
$(eval $(call BuildPackage,kea-dhcp6))
$(eval $(call BuildPackage,kea-dhcp-ddns))
$(eval $(call BuildPackage,kea-admin))
$(eval $(call BuildPackage,kea-hook-ha))
$(eval $(call BuildPackage,kea-hook-lease-cmds))
$(eval $(call BuildPackage,kea-lfc))
$(eval $(call BuildPackage,kea-perfdhcp))
$(eval $(call BuildPackage,kea-shell))
$(eval $(call BuildPackage,kea-uci))
