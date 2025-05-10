include $(TOPDIR)/rules.mk

PKG_NAME:=gl-mudi-mcu
PKG_VERSION:=1.0.0

PKG_MAINTAINER:=Yoonji Park <koreapyj@dcmys.kr>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE.md

include $(INCLUDE_DIR)/package.mk

define Package/gl-mudi-mcu
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=glinet GL-E750 MCU utils
  PKGARCH:=all
endef

define Package/gl-mudi-mcu/description
glinet GL-E750 MCU utils
endef

define Package/gl-mudi-mcu/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/gl-mudi-mcu.sh $(1)/usr/bin/gl-mudi-mcu

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/gl-mudi-mcu.init $(1)/etc/init.d/gl-mudi-mcu

	$(INSTALL_DIR) $(1)/etc/rc.button
	$(INSTALL_BIN) ./files/BTN_0 $(1)/etc/rc.button/BTN_0

	$(INSTALL_DIR) $(1)/etc/hotplug.d/net
	$(INSTALL_DATA) ./files/99-gl-mudi-mcu $(1)/etc/hotplug.d/net
endef

define Build/Configure
endef

define Build/Compile
endef

$(eval $(call BuildPackage,gl-mudi-mcu))
