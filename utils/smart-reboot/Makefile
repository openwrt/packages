include $(TOPDIR)/rules.mk

PKG_NAME:=smart-reboot
PKG_VERSION:=1
PKG_RELEASE:=4

PKG_MAINTAINER:=Min Choi <3387910@naver.com>
PKG_LICENSE:=GPL-2.0-or-later

include $(INCLUDE_DIR)/package.mk

define Package/smart-reboot
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Smart reboot based on network idle state
  DEPENDS:=+busybox +uci +ucode +ucode-mod-uci +ucode-mod-log +ucode-mod-fs
endef

define Package/smart-reboot/description
Reboot router at configured dawn time only when monitored interfaces are idle.
endef

define Package/smart-reboot/conffiles
/etc/config/smart-reboot
endef

define Build/Compile
	true
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
