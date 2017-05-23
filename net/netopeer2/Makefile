#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# Warning by default OpenWrt does not have a root password which is necessery for NETCONF server.

include $(TOPDIR)/rules.mk

PKG_NAME:=netopeer2

PKG_LICENSE:=BSD-3-Clause
PKG_MAINTAINER:=Mislav Novakovic <mislav.novakovic@sartura.hr>

PKG_VERSION:=0.3.65

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=c204b59f9c2bb7e63eb907f33c44adbf208295ee
PKG_MIRROR_HASH:=61a2b3e0ee9a3cf2f73715843f059c79292446ad3643f4eeb85d48d1e185c3b9
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/CESNET/Netopeer2.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_SOURCE_VERSION)

PKG_BUILD_ROOT:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)
PKG_BUILD_DIR:=$(PKG_BUILD_ROOT)

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/netopeer2-server
  SECTION:=util
  CATEGORY:=Utilities
  TITLE:=NETCONF server
  URL:=$(PKG_SOURCE_URL)
  DEPENDS:=+libpthread +libyang +libnetconf2 +netopeer2-keystored +libsysrepo +sysrepocfg +sysrepoctl +sysrepod
endef

define Package/netopeer2-cli
  SECTION:=util
  CATEGORY:=Utilities
  TITLE:=Netopeer2 cli tool
  URL:=$(PKG_SOURCE_URL)
  DEPENDS:=+libpthread +libyang +libnetconf2 +libopenssl
endef

define Package/netopeer2-keystored
  SECTION:=util
  CATEGORY:=Utilities
  TITLE:=Netopeer2 key store management
  URL:=$(PKG_SOURCE_URL)
  DEPENDS:=+libopenssl +libsysrepo +sysrepo-plugind +sysrepocfg +sysrepoctl
endef

define Package/netopeer2/description
 Netopeer2 is a set of tools implementing network configuration tools based on the NETCONF
 Protocol. This is the second generation of the toolset, originally available as the Netopeer
 project. Netopeer2 is based on the new generation of the NETCONF and YANG libraries -
 libyang and libnetconf2. The Netopeer server uses sysrepo as a NETCONF datastore implementation.
endef

CMAKE_OPTIONS += \
	-DCMAKE_INSTALL_PREFIX:PATH=/usr \
	-DCMAKE_BUILD_TYPE:STRING=Release \
	-DKEYSTORED_KEYS_DIR:STRING=/etc/keystored/keys

define Build/Configure
	$(eval PKG_BUILD_DIR:=$(PKG_BUILD_ROOT)/server)
	$(call Build/Configure/Default)

	$(eval PKG_BUILD_DIR:=$(PKG_BUILD_ROOT)/cli)
	$(call Build/Configure/Default)

	$(eval PKG_BUILD_DIR:=$(PKG_BUILD_ROOT)/keystored)
	$(call Build/Configure/Default)
endef

define Build/Compile
	$(eval PKG_BUILD_DIR:=$(PKG_BUILD_ROOT)/server)
	$(call Build/Compile/Default)

	$(eval PKG_BUILD_DIR:=$(PKG_BUILD_ROOT)/cli)
	$(call Build/Compile/Default)

	$(eval PKG_BUILD_DIR:=$(PKG_BUILD_ROOT)/keystored)
	$(call Build/Compile/Default)
endef

define Package/netopeer2-server/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_ROOT)/server/netopeer2-server $(1)/bin/

	$(INSTALL_DIR) $(1)/etc/sysrepo/yang
	$(INSTALL_DATA) $(PKG_BUILD_ROOT)/modules/ietf-ssh-server.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_ROOT)/modules/ietf-tls-server.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_ROOT)/modules/iana-crypt-hash.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_ROOT)/modules/ietf-x509-cert-to-name.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_ROOT)/modules/ietf-netconf-server.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_ROOT)/modules/ietf-netconf-server.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_ROOT)/modules/ietf-system.yang $(1)/etc/sysrepo/yang/

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/netopeer2-server.default $(1)/etc/uci-defaults/99_netopeer2-server

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/netopeer2-server.init $(1)/etc/init.d/netopeer2-server

	$(INSTALL_DIR) $(1)/usr/share/netopeer2-server
	$(INSTALL_DATA) ./files/stock_config.xml $(1)/usr/share/netopeer2-server
endef

define Package/netopeer2-cli/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_ROOT)/cli/netopeer2-cli $(1)/bin/
endef

define Package/netopeer2-keystored/install
	$(INSTALL_DIR) $(1)/usr/lib/sysrepo/plugins/
	$(INSTALL_BIN) $(PKG_BUILD_ROOT)/keystored/libkeystored.so $(1)/usr/lib/sysrepo/plugins/

	$(INSTALL_DIR) $(1)/etc/sysrepo/yang
	$(INSTALL_DATA) $(PKG_BUILD_ROOT)/modules/ietf-keystore.yang $(1)/etc/sysrepo/yang

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/netopeer2-keystored.default $(1)/etc/uci-defaults/97_netopeer2-keystored

	$(INSTALL_DIR) $(1)/usr/share/netopeer2-keystored
	$(INSTALL_DATA) $(PKG_BUILD_ROOT)/keystored/stock_key_config.xml $(1)/usr/share/netopeer2-keystored

	$(INSTALL_DIR) $(1)/etc/keystored/keys
	#$(INSTALL_DATA) ./files/ssh_host_rsa_key.pem $(1)/etc/keystored/keys
	#$(INSTALL_DATA) ./files/ssh_host_rsa_key.pub.pem $(1)/etc/keystored/keys
	#ssh key name is specified in stock_key_config.xml file, you will need to provide the ssh keys yourself.
endef

$(eval $(call BuildPackage,netopeer2-server))
$(eval $(call BuildPackage,netopeer2-cli))
$(eval $(call BuildPackage,netopeer2-keystored))
