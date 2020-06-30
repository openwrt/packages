#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# Warning by default OpenWrt does not have a root password which is necessery for NETCONF server.

include $(TOPDIR)/rules.mk

PKG_NAME:=Netopeer2
PKG_VERSION:=1.1.27
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/CESNET/Netopeer2/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=e3914aae78d19f445a37ef37408f7ce209ebf0b05deb412b1bc56a021448885f

PKG_MAINTAINER:=Mislav Novakovic <mislav.novakovic@sartura.hr>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/netopeer2-keystored/config
  source "$(SOURCE)/Config_keystored.in"
endef

define Package/netopeer2-server
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=NETCONF server
  URL:=https://github.com/CESNET/Netopeer2
  DEPENDS:=+libcurl +libpthread +libyang +libnetconf2 +netopeer2-keystored +libsysrepo +sysrepocfg +sysrepoctl +sysrepo
  MENU:=1
endef

define Package/netopeer2-cli
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Netopeer2 cli tool
  URL:=https://github.com/CESNET/Netopeer2
  DEPENDS:=+libpthread +libyang +libnetconf2 +libopenssl
endef

define Package/netopeer2-keystored
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Netopeer2 key store management
  URL:=https://github.com/CESNET/Netopeer2
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
	-DGENERATE_HOSTKEY:BOOL=OFF \
	-DINSTALL_MODULES:BOOL=OFF \
	-DCMAKE_BUILD_TYPE=release

#-DKEYSTORED_KEYS_DIR:STRING=/etc/keystored/keys \

define Package/netopeer2-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/netopeer2-server $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/sysrepo/yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-ssh-server@2019-07-02.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-tls-server@2019-07-02.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/iana-crypt-hash@2014-08-06.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-x509-cert-to-name@2014-12-10.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-netconf-server@2019-07-02.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-netconf-monitoring@2010-10-04.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-netconf-acm@2018-02-14.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-netconf-nmda@2019-01-07.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-netconf@2013-09-29.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-datastores@2017-08-17.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-crypto-types@2019-07-02.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/iana-crypt-hash@2014-08-06.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-tcp-server@2019-07-02.yang $(1)/etc/sysrepo/yang/

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/netopeer2-server.default $(1)/etc/uci-defaults/98_netopeer2-server

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/netopeer2-server.init $(1)/etc/init.d/netopeer2-server

	$(INSTALL_DIR) $(1)/usr/share/netopeer2-server
	$(INSTALL_DATA) ./files/stock_config.xml $(1)/usr/share/netopeer2-server
endef

define Package/netopeer2-cli/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/netopeer2-cli $(1)/usr/bin/
endef

define Package/netopeer2-keystored/install
	$(INSTALL_DIR) $(1)/etc/sysrepo/yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-keystore@2019-07-02.yang $(1)/etc/sysrepo/yang/

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

endef

$(eval $(call BuildPackage,netopeer2-server))
$(eval $(call BuildPackage,netopeer2-cli))
$(eval $(call BuildPackage,netopeer2-keystored))
