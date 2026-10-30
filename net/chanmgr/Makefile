# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=chanmgr
PKG_VERSION:=1.0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/lucascbd/chanmgr/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=68eab6ecbed7bd1202729daa1ad15a9f5d4ae549265baddb263ac963bf3864ca

PKG_MAINTAINER:=Lucas Dias <lucascbdias@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/chanmgr
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=WirelessAPD
  TITLE:=Periodic Wi-Fi channel optimizer
  URL:=https://github.com/lucascbd/chanmgr
  DEPENDS:=+ucode +ucode-mod-fs +ucode-mod-ubus +ucode-mod-uci \
	+rpcd +rpcd-mod-ucode +iw +uclient-fetch
  PKGARCH:=all
endef

define Package/chanmgr/description
  Periodically measures Wi-Fi channel congestion (passive survey sampling
  plus scheduled off-channel scans) and moves radios to the least
  congested channels. Access point radios switch with channel switch
  announcements, without disconnecting clients; radios that also carry
  802.11s mesh links are restarted on the new channel instead, with an
  automatic rollback if the mesh does not come back. Several access
  points can be planned jointly from one controller, so they also avoid
  each other. Runs in recommend-only mode by default.
endef

define Package/chanmgr/conffiles
/etc/config/chanmgr
endef

define Build/Compile
endef

define Package/chanmgr/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/usr/sbin/chanmgr $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/share/ucode/chanmgr
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/usr/share/ucode/chanmgr/*.uc $(1)/usr/share/ucode/chanmgr/
	$(INSTALL_DIR) $(1)/usr/share/rpcd/ucode
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/usr/share/rpcd/ucode/chanmgr.uc $(1)/usr/share/rpcd/ucode/
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/usr/share/rpcd/acl.d/chanmgr-agent.json $(1)/usr/share/rpcd/acl.d/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/chanmgr.config $(1)/etc/config/chanmgr
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/chanmgr.init $(1)/etc/init.d/chanmgr
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) ./files/chanmgr.keep $(1)/lib/upgrade/keep.d/chanmgr
endef

define Package/chanmgr/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || /etc/init.d/rpcd reload
exit 0
endef

$(eval $(call BuildPackage,chanmgr))
