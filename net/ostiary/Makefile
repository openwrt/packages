include $(TOPDIR)/rules.mk

PKG_NAME:=ostiary
PKG_VERSION:=4.0
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0-only
PKG_MAINTAINER:=Chris Geraghty <cgretski@hotmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/ostiary-$(PKG_VERSION)
PKG_SOURCE:=ostiary-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://ingles.homeunix.net/software/ost/latest/
PKG_HASH:=1b6a0a8a17fd3aa0f6511cdda81558d54f11023a0c953201ddaaef35f56a82c4
PKG_CAT:=zcat

include $(INCLUDE_DIR)/package.mk

define Package/ostiary
  SECTION:=base
  CATEGORY:=Network
  TITLE:=Secure remote execution utility
  URL:=http://ingles.homeunix.net/software/ost/index.html
endef

define Package/ostiary/description
 Replay-resistent predefined remote-command trigger  
endef

define Package/ostiary/conffiles
/etc/ostiary.cfg
/etc/init.d/ostiaryd
endef

define Build/Compile
	 $(call Build/Compile/Default,all)
endef

define Package/ostiary/install
	 $(INSTALL_DIR) $(1)/usr/bin
	 $(INSTALL_BIN) $(PKG_BUILD_DIR)/ostiaryd $(1)/usr/bin/
	 $(INSTALL_BIN) $(PKG_BUILD_DIR)/ostclient $(1)/usr/bin/
	 $(INSTALL_DIR) $(1)/etc
	 $(INSTALL_CONF) $(PKG_BUILD_DIR)/tests/ostiary.cfg $(1)/etc/ostiary.cfg
	 $(INSTALL_DIR) $(1)/etc/init.d
	 $(INSTALL_BIN) ./files/ostiaryd.init $(1)/etc/init.d/ostiary
endef

define Package/postinst
endef

$(eval $(call BuildPackage,ostiary))
