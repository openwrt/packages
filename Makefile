#
# Copyright (C) 2007 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nodogsplash
PKG_VERSION:=0.9_beta9.9.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://kokoro.ucsd.edu/nodogsplash/ \
	http://kokoro.ucsd.edu/nodogsplash/old/
PKG_MD5SUM:=142f6b761a0ef93bb3e8557e1f53bc56

include $(INCLUDE_DIR)/package.mk

define Package/nodogsplash
  SUBMENU:=Captive Portals
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpthread +iptables-mod-ipopt
  TITLE:=Open public network gateway daemon
  URL:=http://kokoro.ucsd.edu/nodogsplash/
endef

define Package/nodogsplash/description
	Nodogsplash offers a simple way to open a free hotspot providing restricted access to an
	internet connection. It is intended for use on wireless access points running OpenWRT
	(but may also work on other Linux-based devices).
endef

define Build/Configure
	$(call Build/Configure/Default,\
		--enable-static \
		--enable-shared \
	)
endef

define Build/Compile
	mkdir -p $(PKG_INSTALL_DIR)/usr/{share{,/doc/$(PKG_NAME)-$(PKG_VERSION)},lib,include{,/nodogsplash},bin,sbin}/
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		mkinstalldirs="$(SHELL) $(PKG_BUILD_DIR)/config/mkinstalldirs" \
		install
endef

define Package/nodogsplash/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc/$(PKG_NAME)
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/$(PKG_NAME).conf $(1)/etc/$(PKG_NAME)/
	$(SED) 's,br0,br-lan,' $(1)/etc/$(PKG_NAME)/$(PKG_NAME).conf
	$(CP) $(PKG_BUILD_DIR)/htdocs $(1)/etc/$(PKG_NAME)/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/$(PKG_NAME).init $(1)/etc/init.d/$(PKG_NAME)
	$(SED) 's,\(do_module_tests "imq"\),#\1,' $(1)/etc/init.d/$(PKG_NAME)
	$(SED) 's,\(do_module_tests "ipt_IMQ"\),#\1,' $(1)/etc/init.d/$(PKG_NAME)
	$(SED) 's,\(do_module_tests "sch_htb"\),#\1,' $(1)/etc/init.d/$(PKG_NAME)
endef

$(eval $(call BuildPackage,nodogsplash))
