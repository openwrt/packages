include $(TOPDIR)/rules.mk

PKG_NAME:=smart-reboot
PKG_RELEASE:=3

include $(INCLUDE_DIR)/package.mk

define Package/smart-reboot
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Smart reboot based on network idle state
  DEPENDS:=+busybox +uci
endef

define Package/smart-reboot/description
Reboot router at configured dawn time only when monitored interfaces are idle.
endef

define Package/smart-reboot/conffiles
/etc/config/smart-reboot
endef

define Build/Compile
endef

define Package/smart-reboot/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/smart-reboot $(1)/etc/config/smart-reboot

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/smart-reboot $(1)/etc/init.d/smart-reboot

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/usr/sbin/smart-reboot-check $(1)/usr/sbin/smart-reboot-check
endef

define Package/smart-reboot/postinst
#!/bin/sh
[ -n "$$IPKG_INSTROOT" ] || {
	/etc/init.d/smart-reboot enable >/dev/null 2>&1
	/etc/init.d/smart-reboot restart >/dev/null 2>&1
}
exit 0
endef

$(eval $(call BuildPackage,smart-reboot))
