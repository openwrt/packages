include $(TOPDIR)/rules.mk

PKG_NAME:=dvmhost
PKG_VERSION:=2025.09.03
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=e9abdf63aa656465438d59f009a83faf5ba69f1f	# R04J32 with hotfixes
PKG_SOURCE_URL:=https://github.com/dvmproject/dvmhost
PKG_MIRROR_HASH:=a0346fa9b3d01349f1fced0af17be01a9346bd416aa19fe575ad767538cd11b8
PKG_BUILD_PARALLEL:=1

PKG_MAINTAINER:=Natalie Moore <natalie@natalielucy.dev>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILE=LICENSE

# disable TUI to save space; pending upstream updates for websocket
CMAKE_OPTIONS+= -DENABLE_TUI_SUPPORT=0 -DDISABLE_WEBSOCKETS=1

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
  TITLE+= (dvmhost)
  DEPENDS+=+libopenssl +libstdcpp
endef

define Package/dvmhost/description
 DVMHost is the host application for a Digital Voice Modem-based radio system.
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

$(eval $(call BuildPackage,dvmhost))
