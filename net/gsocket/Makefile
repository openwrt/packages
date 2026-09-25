include $(TOPDIR)/rules.mk

PKG_NAME:=gsocket
PKG_VERSION:=1.4.39
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/hackerschoice/gsocket/releases/download/v$(PKG_VERSION)/
PKG_HASH:=2042b3773e03285939fe7f0d0597a77c8d4958644b1d8a366cc71d384f1e5c30

PKG_MAINTAINER:=Ralf Kaiser <skyper@thc.org>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/gsocket
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libopenssl
  TITLE:=Connect like there is no firewall
  URL:=https://gsocket.io
endef

define Package/gsocket/description
  Global Socket allows two workstations on different private networks to
  communicate with each other. Through firewalls and through NAT - like
  there is no firewall.

  The TCP connection is secured with AES-256 and using OpenSSL's SRP
  protocol (RFC 5054). It does not require a PKI and has forward
  secrecy and (optional) TOR support.

  The gsocket tools derive temporary session keys and IDs and connect
  two TCP pipes through the Global Socket Relay Network (GSRN). This is 
  done regardless and independent of the local IP Address or geographical
  location.

  The session keys (secrets) never leave the workstation. The GSRN sees only
  the encrypted traffic.

  The workhorse is 'gs-netcat' which opens a ssh-like interactive PTY
  command shell to a remote workstation (which resides on a private and
  remote network and/or behind a firewall).
endef

define Build/Configure
 $(call Build/Configure/Default,--with-linux-headers=$(LINUX_DIR) --libdir=$(STAGING_DIR)/usr/lib --includedir=$(STAGING_DIR)/usr/include)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
	LD="$(TARGET_CXX)" \
	all
endef

define Package/gsocket/install
	$(INSTALL_DIR)	$(1)/bin
	$(INSTALL_DIR)	$(1)/share/gsocket
	$(INSTALL_DIR)	$(1)/lib
	$(INSTALL_DIR)	$(1)/etc
	$(INSTALL_BIN)	$(PKG_BUILD_DIR)/tools/gs-sftp                    $(1)/bin/
	$(INSTALL_BIN)	$(PKG_BUILD_DIR)/tools/gs-mount                   $(1)/bin/
	$(INSTALL_BIN)	$(PKG_BUILD_DIR)/tools/blitz                      $(1)/bin/
	$(INSTALL_BIN)	$(PKG_BUILD_DIR)/tools/gsocket                    $(1)/bin/
	$(INSTALL_BIN)	$(PKG_BUILD_DIR)/tools/gs-netcat                  $(1)/bin/
	$(INSTALL_BIN)	$(PKG_BUILD_DIR)/tools/gs_funcs                   $(1)/share/gsocket/
	$(INSTALL_BIN)	$(PKG_BUILD_DIR)/tools/gsocket_uchroot_dso.so.0   $(1)/lib/
	$(INSTALL_BIN)	$(PKG_BUILD_DIR)/tools/gsocket_dso.so.0           $(1)/lib/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/tools/gsocket.conf               $(1)/etc/
endef

$(eval $(call BuildPackage,gsocket))

