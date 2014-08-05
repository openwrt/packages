#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=emailrelay
PKG_VERSION:=1.9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-src.tar.gz
PKG_SOURCE_URL:=@SF/emailrelay/$(PKG_VERSION)
PKG_MD5SUM:=0892fbf993407c6b5a16f96e23299b62
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_CAT :=zcat

include $(INCLUDE_DIR)/package.mk

define Package/emailrelay
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+uclibcxx +libopenssl
  SUBMENU:=Web Servers/Proxies
  TITLE:=A simple SMTP proxy and store-and-forward message transfer agent (MTA).
  URL:=http://emailrelay.sourceforge.net/
  MAINTAINER := Federico Di Marco <fededim@gmail.com>
endef


define Package/emailrelay/description
 Simple SMTP proxy and store-and-forward message transfer agent (MTA). 
 
 When running as a proxy all e-mail messages can be passed through 
  a user-defined program, such as a spam filter, which can drop, 
  re-address or edit messages as they pass through. When running 
  as a store-and-forward MTA incoming messages are stored in a 
  local spool directory, and then forwarded to the next SMTP 
  server on request.
endef


define Package/emailrelay/conffiles
/etc/emailrelay.auth
endef



CONFIGURE_VARS += \
        CXXFLAGS="-nostdinc++"  \
	LDFLAGS="-nodefaultlibs" \
	LIBS="-lgcc -lc -luClibc++ -lgcc_s"


define Build/Configure
  $(call Build/Configure/Default,--with-openssl)
  endef
	
define Package/emailrelay/install	
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/main/emailrelay $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/main/emailrelay-filter-copy $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/main/emailrelay-passwd $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/main/emailrelay-poke $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/main/emailrelay-submit $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) files/$(PKG_NAME).auth $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/$(PKG_NAME).init $(1)/etc/init.d/$(PKG_NAME)
endef

$(eval $(call BuildPackage,emailrelay))
