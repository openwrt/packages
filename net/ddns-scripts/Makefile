include $(TOPDIR)/rules.mk

PKG_NAME:=ddns-scripts
PKG_VERSION:=1.0.0
PKG_RELEASE:=22

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/ddns-scripts
	SECTION:=net
	CATEGORY:=Network
        SUBMENU:=IP Addresses and Names
	TITLE:=Dynamic DNS Scripts
	PKGARCH:=all
endef

define Package/ddns-scripts/description
	A highly configurable set of scripts for doing
	dynamic dns updates
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/ddns-scripts/conffiles
/etc/config/ddns
endef

define Package/ddns-scripts/install
	$(INSTALL_DIR) $(1)
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/ddns $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,ddns-scripts))
