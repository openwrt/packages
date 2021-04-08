include $(TOPDIR)/rules.mk

PKG_NAME:=suricata-update
PKG_VERSION:=1.1.2
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	true
endef

define Build/Configure
	true
endef

define Build/Compile
	true
endef

define Package/suricata-update
    SUBMENU:=Firewall
    SECTION:=net
    CATEGORY:=Network
    DEPENDS:=+suricata6 +python3-pip +python3-yaml
    TITLE:=OISF Suricata IDS Update Utility
    URL:=https://www.openinfosecfoundation.org/
endef

define Package/suricata-update/description
 Suricata-Update provides updated ruleset lists for the Suricata IDS/IPS/NMS
endef

define Package/suricata-update/conffiles
/etc/config/suricata-update
endef

define Package/suricata-update/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/suricata-update $(1)/etc/init.d/suricata-update

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/suricata-update $(1)/etc/config/suricata-update
endef

$(eval $(call BuildPackage,suricata-update))

