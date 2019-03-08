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

PKG_NAME:=bmx7

PKG_SOURCE_PROTO:=git

PKG_SOURCE_URL:=https://github.com/bmx-routing/bmx7.git

PKG_REV:=cc245a22e54b5e110384485f18d9b805c91d8b71
PKG_MIRROR_HASH:=378228450b7790bb07b1d478f123e9196c1040d9f55ec42e83090249574a3d6b
PKG_VERSION:=r2019030802
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0

PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += $(FPIC)

MAKE_ARGS += EXTRA_CFLAGS="$(TARGET_CFLAGS) -I. -I$(STAGING_DIR)/usr/include -DCRYPTLIB=MBEDTLS_2_8_0 -DCORE_LIMIT=20000 -DTRAFFIC_DUMP -DNO_TRACE_FUNCTION_CALLS -DBMX7_LIB_IWINFO"

MAKE_ARGS += \
        EXTRA_LDFLAGS="$(TARGET_LDFLAGS) -L$(STAGING_DIR)/usr/lib -liwinfo" \
        GIT_REV="$(PKG_REV)" \
        CC="$(TARGET_CC)" \
        INSTALL_DIR="$(PKG_INSTALL_DIR)" \
        build_all

define Package/bmx7/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=BMX7 layer 3 routing daemon
  URL:=http://github.com/bmx-routing/bmx7
  MAINTAINER:=Axel Neumann <neumann@cgws.de>
  DEPENDS:=+zlib +libmbedtls +libiwinfo
endef

define Package/bmx7/description
BMX7 routing daemon supporting securely-entrusted IPv6 (and IPv4in6) routing
endef

define Package/bmx7
  $(call Package/bmx7/Default)
  MENU:=1
endef

define Package/bmx7-uci-config
  $(call Package/bmx7/Default)
  DEPENDS:=bmx7 +libuci
  TITLE:=configuration plugin based on uci (recommended!)
endef

define Package/bmx7-iwinfo
  $(call Package/bmx7/Default)
  DEPENDS:=bmx7 +libiwinfo
  TITLE:=link characteristics plugin based on libiwinfo (recommended!)
endef

define Package/bmx7-topology
  $(call Package/bmx7/Default)
  DEPENDS:=bmx7
  TITLE:=topology plugin
endef

define Package/bmx7-json
  $(call Package/bmx7/Default)
  DEPENDS:=bmx7 +libjson-c
  TITLE:=json plugin based on json-c
endef

define Package/bmx7-sms
  $(call Package/bmx7/Default)
  DEPENDS:=bmx7
  TITLE:=sms plugin
endef

define Package/bmx7-tun
  $(call Package/bmx7/Default)
  DEPENDS:=bmx7 +kmod-ip6-tunnel +kmod-iptunnel6 +kmod-tun
  TITLE:=ipip-based tunnel plugin (recommended!)
endef

define Package/bmx7-table
  $(call Package/bmx7/Default)
  DEPENDS:=bmx7 +bmx7-tun
  TITLE:=plugin to announce routes from tables via tunnels
endef

define Build/Configure
	mkdir -p $(PKG_INSTALL_DIR)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_ARGS)
endef

define Package/bmx7/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bmx7 $(1)/usr/sbin/bmx7
endef

define Package/bmx7/postinst
#!/bin/sh
# # check if we are on real system
if [ -z "$${IPKG_INSTROOT}" ]; then
	if [ -f /etc/sysupgrade.conf ] && ! grep bmx7 /etc/sysupgrade.conf; then
		echo /etc/bmx7 >> /etc/sysupgrade.conf
        fi
fi
endef


define Package/bmx7-uci-config/conffiles
/etc/config/bmx7
/etc/bmx7
endef

define Package/bmx7-uci-config/install
	$(INSTALL_DIR) $(1)/usr/lib $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/bmx7_uci_config/bmx7_config.so $(1)/usr/lib/bmx7_config.so
	$(INSTALL_BIN) ./files/etc/init.d/bmx7 $(1)/etc/init.d/bmx7
	$(INSTALL_DATA) ./files/etc/config/bmx7 $(1)/etc/config/bmx7
endef

define Package/bmx7-iwinfo/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/bmx7_iwinfo/bmx7_iwinfo.so $(1)/usr/lib/bmx7_iwinfo.so
endef

define Package/bmx7-topology/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/bmx7_topology/bmx7_topology.so $(1)/usr/lib/bmx7_topology.so
endef

define Package/bmx7-json/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/bmx7_json/bmx7_json.so $(1)/usr/lib/bmx7_json.so
endef

define Package/bmx7-sms/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/bmx7_sms/bmx7_sms.so $(1)/usr/lib/bmx7_sms.so
endef

define Package/bmx7-tun/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/bmx7_tun/bmx7_tun.so $(1)/usr/lib/bmx7_tun.so
endef

define Package/bmx7-table/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/bmx7_table/bmx7_table.so $(1)/usr/lib/bmx7_table.so
endef


$(eval $(call BuildPackage,bmx7))
$(eval $(call BuildPackage,bmx7-uci-config))
$(eval $(call BuildPackage,bmx7-iwinfo))
$(eval $(call BuildPackage,bmx7-topology))
$(eval $(call BuildPackage,bmx7-json))
$(eval $(call BuildPackage,bmx7-sms))
$(eval $(call BuildPackage,bmx7-table))
$(eval $(call BuildPackage,bmx7-tun))
