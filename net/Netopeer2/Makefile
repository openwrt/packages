#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# Warning by default OpenWrt does not have a root password which is necessery for NETCONF server.

include $(TOPDIR)/rules.mk

PKG_NAME:=Netopeer2
PKG_VERSION:=0.7-r1
PKG_RELEASE:=2

PKG_LICENSE:=BSD-3-Clause
PKG_MAINTAINER:=Mislav Novakovic <mislav.novakovic@sartura.hr>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/CESNET/Netopeer2/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=040013d1e315c62c496b704475665165578c374ffb387cbbff422cf8898d3a12

CMAKE_INSTALL:=1

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/netopeer2-keystored/config
  source "$(SOURCE)/Config_keystored.in"
endef

define Package/netopeer2-server
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=NETCONF server
  URL:=$(PKG_SOURCE_URL)
  DEPENDS:=+libcurl +libpthread +libyang +libnetconf2 +netopeer2-keystored +libsysrepo +sysrepocfg +sysrepoctl +sysrepo
  MENU:=1
endef

define Package/netopeer2-cli
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Netopeer2 cli tool
  URL:=$(PKG_SOURCE_URL)
  DEPENDS:=+libpthread +libyang +libnetconf2 +libopenssl
endef

define Package/netopeer2-keystored
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Netopeer2 key store management
  URL:=$(PKG_SOURCE_URL)
  DEPENDS:=+libopenssl +libsysrepo +sysrepo +sysrepocfg +sysrepoctl +SSH_KEYS:openssh-keygen
  MENU:=1
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
	-DKEYSTORED_KEYS_DIR:STRING=/etc/keystored/keys \
	-DENABLE_CONFIGURATION:BOOL=OFF \
	-DMODEL_INSTALL:BOOL=OFF \
	-DSSH_KEY_INSTALL:BOOL=OFF

define Package/netopeer2-server/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/server/netopeer2-server $(1)/bin/

	$(INSTALL_DIR) $(1)/etc/sysrepo/yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-ssh-server.yang $(1)/etc/sysrepo/yang/ietf-ssh-server@2016-11-02.yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-tls-server.yang $(1)/etc/sysrepo/yang/ietf-tls-server@2016-11-02.yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/iana-crypt-hash.yang $(1)/etc/sysrepo/yang/iana-crypt-hash@2014-08-06.yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-x509-cert-to-name.yang $(1)/etc/sysrepo/yang/ietf-x509-cert-to-name@2014-12-10.yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-netconf-server.yang $(1)/etc/sysrepo/yang/ietf-netconf-server@2016-11-02.yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-netconf-monitoring.yang $(1)/etc/sysrepo/yang/ietf-netconf-monitoring@2010-10-04.yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-netconf-with-defaults.yang $(1)/etc/sysrepo/yang/ietf-netconf-with-defaults@2011-06-01.yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-system.yang $(1)/etc/sysrepo/yang/ietf-system@2014-08-06.yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-datastores.yang $(1)/etc/sysrepo/yang/ietf-datastores@2017-08-17.yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-yang-library.yang $(1)/etc/sysrepo/yang/ietf-yang-library@2018-01-17.yang

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/netopeer2-server.default $(1)/etc/uci-defaults/98_netopeer2-server

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/netopeer2-server.init $(1)/etc/init.d/netopeer2-server

	$(INSTALL_DIR) $(1)/usr/share/netopeer2-server
	$(INSTALL_DATA) ./files/stock_config.xml $(1)/usr/share/netopeer2-server
endef

define Package/netopeer2-cli/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cli/netopeer2-cli $(1)/bin/
endef

define Package/netopeer2-keystored/install
	$(INSTALL_DIR) $(1)/usr/lib/sysrepo/plugins/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/keystored/libkeystored.so $(1)/usr/lib/sysrepo/plugins/

	$(INSTALL_DIR) $(1)/etc/sysrepo/yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-keystore.yang $(1)/etc/sysrepo/yang/ietf-keystore@2016-10-31.yang

	$(INSTALL_DIR) $(1)/etc/uci-defaults

	$(INSTALL_DIR) $(1)/etc/keystored/keys
ifeq ($(CONFIG_SSH_KEYS),y)
	$(INSTALL_BIN) ./files/netopeer2-keystored-keygen.default $(1)/etc/uci-defaults/97_netopeer2-keystored
else
	$(INSTALL_BIN) ./files/netopeer2-keystored.default $(1)/etc/uci-defaults/97_netopeer2-keystored
	#ssh key name is specified in ./files/stock_config.xml file, you will need to provide the ssh keys yourself.
	$(INSTALL_DATA) ./files/ssh_host_rsa_key.pem $(1)/etc/keystored/keys
	$(INSTALL_DATA) ./files/ssh_host_rsa_key.pub.pem $(1)/etc/keystored/keys
endif

	$(INSTALL_DIR) $(1)/usr/share/netopeer2-keystored
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/keystored/stock_key_config.xml $(1)/usr/share/netopeer2-keystored
endef

$(eval $(call BuildPackage,netopeer2-server))
$(eval $(call BuildPackage,netopeer2-cli))
$(eval $(call BuildPackage,netopeer2-keystored))
