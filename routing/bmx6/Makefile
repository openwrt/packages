#    Copyright (C) 2011 Fundacio Privada per a la Xarxa Oberta, Lliure i Neutral guifi.net
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
#    The full GNU General Public License is included in this distribution in
#    the file called "COPYING".
#
# Contibutors:
#	Axel Neumann, Simó Albert i Beltran, Pau Escrich
#


include $(TOPDIR)/rules.mk

PKG_NAME:=bmx6

PKG_SOURCE_PROTO:=git

PKG_SOURCE_URL:=https://github.com/bmx-routing/bmx6.git

PKG_REV:=0312168aaa384379ccbefd4b2d936fc698664d5b
PKG_MIRROR_HASH:=98acdbda8a8cadadf8141c7b8a17b6417112f70f3211b86abad23a8c7a28be10
PKG_VERSION:=r2018020902
PKG_RELEASE:=5
PKG_LICENSE:=GPL-2.0

PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += $(FPIC)

MAKE_ARGS += \
	EXTRA_CFLAGS="$(TARGET_CFLAGS) -I. -I$(STAGING_DIR)/usr/include -DNO_DEBUG_ALL -DNO_DEBUG_DUMP" \
	EXTRA_LDFLAGS="-L$(STAGING_DIR)/usr/lib " \
	GIT_REV="$(PKG_REV)" \
	CC="$(TARGET_CC)" \
	INSTALL_DIR="$(PKG_INSTALL_DIR)" \
	STRIP="/bin/false" \
	build_all

define Package/bmx6/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=BMX6 layer 3 routing daemon
  URL:=http://bmx6.net/
  MAINTAINER:=Axel Neumann <neumann@cgws.de>
  DEPENDS:=+kmod-ip6-tunnel +kmod-iptunnel6 +kmod-tun
endef

define Package/bmx6/description
BMX6 layer 3 routing daemon supporting IPv4, IPv6, and IPv4 over IPv6
endef

define Package/bmx6
  $(call Package/bmx6/Default)
  MENU:=1
endef

define Package/bmx6-uci-config
  $(call Package/bmx6/Default)
  DEPENDS:=bmx6 +libuci
  TITLE:=configuration plugin based on uci (recommended!)
endef

define Package/bmx6-json
  $(call Package/bmx6/Default)
  DEPENDS:=bmx6 +libjson-c
  TITLE:=json plugin based on json-c
endef

define Package/bmx6-sms
  $(call Package/bmx6/Default)
  DEPENDS:=bmx6
  TITLE:=sms plugin
endef

#define Package/bmx6-quagga
#  $(call Package/bmx6/Default)
#  DEPENDS:=bmx6 +qmp-quagga @BROKEN
#  TITLE:=bmx6 quagga plugin to redistribute/export routes (needs manet/bmx6 patched quagga 0.99.21)
#endef

define Package/bmx6-table
  $(call Package/bmx6/Default)
  DEPENDS:=bmx6
  TITLE:=bmx6 table plugin to automatic announce routing-table routes via ip6ip tunnels
endef

define Build/Configure
	mkdir -p $(PKG_INSTALL_DIR)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_ARGS)
endef

define Package/bmx6/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bmx6 $(1)/usr/sbin/bmx6
endef

define Package/bmx6-uci-config/conffiles
/etc/config/bmx6
endef

define Package/bmx6-uci-config/install
	$(INSTALL_DIR) $(1)/usr/lib $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/bmx6_uci_config/bmx6_config.so $(1)/usr/lib/bmx6_config.so
	$(INSTALL_BIN) ./files/etc/init.d/bmx6 $(1)/etc/init.d/bmx6
	$(INSTALL_DATA) ./files/etc/config/bmx6 $(1)/etc/config/bmx6
endef

define Package/bmx6-json/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/bmx6_json/bmx6_json.so $(1)/usr/lib/bmx6_json.so
endef

define Package/bmx6-sms/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/bmx6_sms/bmx6_sms.so $(1)/usr/lib/bmx6_sms.so
endef

define Package/bmx6-table/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/bmx6_table/bmx6_table.so $(1)/usr/lib/bmx6_table.so
endef

#define Package/bmx6-quagga/install
#	$(INSTALL_DIR) $(1)/usr/lib
#	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/bmx6_quagga/bmx6_quagga.so $(1)/usr/lib/bmx6_quagga.so
#endef

$(eval $(call BuildPackage,bmx6))
$(eval $(call BuildPackage,bmx6-uci-config))
$(eval $(call BuildPackage,bmx6-json))
$(eval $(call BuildPackage,bmx6-sms))
#$(eval $(call BuildPackage,bmx6-quagga))
$(eval $(call BuildPackage,bmx6-table))
