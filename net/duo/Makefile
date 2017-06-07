include $(TOPDIR)/rules.mk

PKG_NAME:=duo
PKG_VERSION:=2014-08-11
PKG_RELEASE:=3
PKG_BUILD_DIR:=$(BUILD_DIR)/duo
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/duosecurity/duo_openvpn.git
PKG_SOURCE:=$(PKG_NAME).tar.gz
PKG_SOURCE_VERSION:=HEAD
PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Jeff Beley <jeff@beley.org>
PKG_LICENSE_FILE=:LICENSE

DUO_PREFIX:=/etc/openvpn/

include $(INCLUDE_DIR)/package.mk

define Package/duo
  SECTION:=base
  CATEGORY:=Network
  DEFAULT:=n
  TITLE:=duo-security
  URL:=http://www.duosecurity.com/
endef

define Package/duo/description
	Multi-factor authentication package for OpenVPN from DUO 
	http://www.duosecurity.com
	
	Note: requires openvpn with plugins enabled
endef


define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(TARGET_CONFIGURE_OPTS) PREFIX=$(DUO_PREFIX)
endef

define Package/duo/install
	$(INSTALL_DIR) $(1)/etc/openvpn
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ca_certs.pem $(1)/etc/openvpn/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/duo_openvpn.py $(1)/etc/openvpn/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/duo_openvpn.so $(1)/etc/openvpn/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/https_wrapper.py $(1)/etc/openvpn/
endef

$(eval $(call BuildPackage,duo))
