include $(TOPDIR)/rules.mk

PKG_NAME:=mtk-hqos
PKG_VERSION:=0.4.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Alexander A <st7105@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/mtk-hqos
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Experimental MediaTek hardware queue configuration
  DEPENDS:=@TARGET_mediatek_filogic +ucode +ucode-mod-fs +ucode-mod-uci +flock +nftables-json
  PKGARCH:=all
endef

define Package/mtk-hqos/conffiles
/etc/config/mtk_hqos
endef

define Build/Prepare
	$(INSTALL_DIR) $(PKG_BUILD_DIR)
	$(INSTALL_DATA) ./COPYING $(PKG_BUILD_DIR)/COPYING
endef

define Build/Compile
endef

define Package/mtk-hqos/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d $(1)/etc/hotplug.d/iface
	$(INSTALL_CONF) ./files/config $(1)/etc/config/mtk_hqos
	$(INSTALL_BIN) ./files/init $(1)/etc/init.d/mtk-hqos
	$(INSTALL_BIN) ./files/hotplug $(1)/etc/hotplug.d/iface/95-mtk-hqos
	$(INSTALL_DIR) $(1)/usr/libexec $(1)/usr/share/ucode/mtk_hqos
	$(INSTALL_BIN) ./files/controller.uc $(1)/usr/libexec/mtk-hqos
	$(INSTALL_DATA) ./files/core.uc $(1)/usr/share/ucode/mtk_hqos/core.uc
endef

define Package/mtk-hqos/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || /etc/init.d/mtk-hqos enable
exit 0
endef

define Package/mtk-hqos/prerm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || /etc/init.d/mtk-hqos stop
exit 0
endef

$(eval $(call BuildPackage,mtk-hqos))
