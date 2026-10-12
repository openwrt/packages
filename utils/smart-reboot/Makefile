include $(TOPDIR)/rules.mk

PKG_NAME:=smart-reboot
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_MAINTAINER:=Min Choi <3387910@naver.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/smart-reboot
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Smart reboot based on network idle state
  DEPENDS:=+ucode +ucode-mod-uci +ucode-mod-log +ucode-mod-fs +ucode-mod-ubus +ucode-mod-uloop
  PKGARCH:=all
endef

define Package/smart-reboot/description
  Reboot router at configured dawn time window only when monitored interfaces are idle.
endef

define Package/smart-reboot/conffiles
/etc/config/smart-reboot
endef

define Build/Compile
endef

define Package/smart-reboot/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/smart-reboot.config $(1)/etc/config/smart-reboot

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/smart-reboot.init $(1)/etc/init.d/smart-reboot

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/smart-reboot.uc $(1)/usr/sbin/smart-reboot
endef

$(eval $(call BuildPackage,smart-reboot))
