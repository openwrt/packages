include $(TOPDIR)/rules.mk

PKG_NAME:=k3screenctrl
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/kazutoiris/k3screenctrl/archive/refs/tags/v$(PKG_VERSION).tar.gz?
PKG_HASH:=cc9927f324ce7e221a2ac3351ec78156719195662cc5bafd5424d340c170cd39
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_MAINTAINER:=Kazuto Iris <hitomi@apache.org>, Hamster Tian <haotia@gmail.com>
PKG_BUILD_DEPENDS:=automake
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS+= -D_GNU_SOURCE

define Package/k3screenctrl
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+coreutils-od +bash +curl @TARGET_bcm53xx_generic_DEVICE_phicomm_k3
  TITLE:=LCD screen controller on PHICOMM K3
  URL:=https://github.com/kazutoiris/k3screenctrl.git
endef

define Package/k3screenctrl/description
  K3 Screen Controller (k3screenctrl) is a program utilizing the LCD screen on PHICOMM K3 to display some stats.
endef

define Package/k3screenctrl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/lib/k3screenctrl
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/lib/k3screenctrl/oui
	$(INSTALL_DIR) $(1)/etc/config

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/k3screenctrl $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/k3screenctrl/wan.sh $(1)/lib/k3screenctrl/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/k3screenctrl/wifi.sh $(1)/lib/k3screenctrl/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/k3screenctrl/port.sh $(1)/lib/k3screenctrl/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/k3screenctrl/basic.sh $(1)/lib/k3screenctrl/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/k3screenctrl/host.sh $(1)/lib/k3screenctrl/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/k3screenctrl/weather.sh $(1)/lib/k3screenctrl/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lib/k3screenctrl/oui/oui.txt $(1)/lib/k3screenctrl/oui/

	$(INSTALL_BIN) ./files/k3screenctrl.init $(1)/etc/init.d/k3screenctrl
	$(INSTALL_CONF) ./files/k3screenctrl.config $(1)/etc/config/k3screenctrl
endef

define Package/k3screenctrl/conffiles
/etc/config/k3screenctrl
endef

$(eval $(call BuildPackage,k3screenctrl))
