# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=tcfilter
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Mark Abe <github@mab.wien>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=

include $(INCLUDE_DIR)/package.mk

define Package/tcfilter
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Traffic Control
  TITLE:=Persistent tc ingress filters (UCI-managed)
  DEPENDS:=+tc-full
  PKGARCH:=all
endef

define Package/tcfilter/description
  Thin UCI front-end that installs raw "tc filter ... ingress" expressions on
  network devices at boot and on interface up, and removes them on stop. The
  match/action part is entered verbatim as tc syntax; the package only manages
  the device, the preference number, enable/disable and persistence.

  Intended for driving hardware tc-flower offload (e.g. the Realtek DSA PIE
  offload) where no higher-level configuration layer exists.
endef

define Package/tcfilter/conffiles
/etc/config/tcfilter
endef

define Build/Compile
endef

define Package/tcfilter/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/tcfilter.config $(1)/etc/config/tcfilter
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/tcfilter.init $(1)/etc/init.d/tcfilter
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./files/tcfilter.hotplug-iface $(1)/etc/hotplug.d/iface/30-tcfilter
	$(INSTALL_DIR) $(1)/etc/hotplug.d/net
	$(INSTALL_DATA) ./files/tcfilter.hotplug-net $(1)/etc/hotplug.d/net/30-tcfilter
endef

$(eval $(call BuildPackage,tcfilter))
