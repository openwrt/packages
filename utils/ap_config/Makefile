include $(TOPDIR)/rules.mk

PKG_NAME:=ap_config
PKG_VERSION:=2021-03-21
PKG_RELEASE:=1

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/ac_server
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=ac_server
  DEPENDS:=+libaxl +libopenssl +libmariadbclient
endef

define Package/ac_client
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=ac_client
  DEPENDS:=+libaxl +libopenssl
endef

define Package/ac_server/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ac_server $(1)/usr/sbin
endef

define Package/ap_client/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ac_client $(1)/usr/sbin
endef

$(eval $(call BuildPackage,ac_server))
$(eval $(call BuildPackage,ac_client))
