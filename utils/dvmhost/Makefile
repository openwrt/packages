include $(TOPDIR)/rules.mk

PKG_NAME:=dvmhost
PKG_VERSION:=2025.09.03
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=e9abdf63aa656465438d59f009a83faf5ba69f1f	# R04J32 with hotfixes
PKG_SOURCE_URL:=https://github.com/dvmproject/dvmhost
PKG_MIRROR_HASH:=a0346fa9b3d01349f1fced0af17be01a9346bd416aa19fe575ad767538cd11b8

PKG_MAINTAINER:=Natalie Moore <natalie@natalielucy.dev>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILE=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk


define Package/dvmhost/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Digital Voice Modem Host application
  URL:=https://github.com/dvmproject/dvmhost
endef


define Package/dvmhost
  $(call Package/dvmhost/Default)
  TITLE+= (minimal)
  DEPENDS+=+libopenssl +libstdcpp
  
  # disable TUI and websockets to save space
  CMAKE_OPTIONS+= -DENABLE_TUI_SUPPORT=0 -DDISABLE_WEBSOCKETS=1
endef

define Package/dvmhost/description
 DVMHost is the host application for a Digital Voice Modem-based radio system.
endef

define Package/dvmhost/conffiles
/etc/dvmhost/config.yml
/etc/dvmhost/iden_table.dat
/etc/dvmhost/peer_list.dat
/etc/dvmhost/rid_acl.dat
/etc/dvmhost/RSSI.dat
endef

define Package/dvmhost/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/dvmhost.init $(1)/etc/init.d/dvmhost
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dvmhost $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/dvmhost
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/configs/config.example.yml $(1)/etc/dvmhost/config.yml
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/configs/iden_table.example.dat $(1)/etc/dvmhost/iden_table.dat
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/configs/peer_list.example.dat $(1)/etc/dvmhost/peer_list.dat
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/configs/rid_acl.example.dat $(1)/etc/dvmhost/rid_acl.dat
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/configs/RSSI.dat $(1)/etc/dvmhost/RSSI.dat
endef


define Package/dvmhost-full
  $(call Package/dvmhost/Default)
  TITLE+= (full)
  DEPENDS+=+libopenssl +libstdcpp +kmod-tun
  CMAKE_OPTIONS+= -DDISABLE_WEBSOCKETS=1
endef

define Package/dvmhost-full/description
  Full suite of DVMHost applications including Host, FNE, Patch, and Bridge.
endef

define Package/dvmhost-full/conffiles
/etc/dvmhost/config.yml
/etc/dvmhost/iden_table.dat
/etc/dvmhost/peer_list.dat
/etc/dvmhost/rid_acl.dat
/etc/dvmhost/RSSI.dat
/etc/dvmhost/adj_site_map.yml
/etc/dvmhost/bridge-config.yml
/etc/dvmhost/fne-config.yml
/etc/dvmhost/fne-sysview.yml
/etc/dvmhost/monitor-config.yml
/etc/dvmhost/patch-config.yml
/etc/dvmhost/peer_list.dat
/etc/dvmhost/talkgroup_rules.yml
endef

define Package/dvmhost-full/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/dvmhost.init $(1)/etc/init.d/dvmhost
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dvmhost $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/dvmhost
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/configs/config.example.yml $(1)/etc/dvmhost/config.yml
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/configs/iden_table.example.dat $(1)/etc/dvmhost/iden_table.dat
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/configs/peer_list.example.dat $(1)/etc/dvmhost/peer_list.dat
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/configs/rid_acl.example.dat $(1)/etc/dvmhost/rid_acl.dat
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/configs/RSSI.dat $(1)/etc/dvmhost/RSSI.dat
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dvmbridge $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dvmcmd $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dvmfne $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dvmpatch $(1)/usr/bin
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/configs/adj_site_map.example.yml $(1)/etc/dvmhost/adj_site_map.yml
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/configs/bridge-config.example.yml $(1)/etc/dvmhost/bridge-config.yml
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/configs/fne-config.example.yml $(1)/etc/dvmhost/fne-config.yml
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/configs/fne-sysview.example.yml $(1)/etc/dvmhost/fne-sysview.yml
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/configs/monitor-config.example.yml $(1)/etc/dvmhost/monitor-config.yml
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/configs/patch-config.example.yml $(1)/etc/dvmhost/patch-config.yml
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/configs/peer_list.example.dat $(1)/etc/dvmhost/peer_list.dat
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/configs/talkgroup_rules.example.yml $(1)/etc/dvmhost/talkgroup_rules.yml
endef


$(eval $(call BuildPackage,dvmhost))
$(eval $(call BuildPackage,dvmhost-full))
