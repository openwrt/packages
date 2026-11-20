# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=switchdev-config
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Andre Brait <andrebrait@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=

include $(INCLUDE_DIR)/package.mk

define Package/switchdev-config
  SECTION:=net
  CATEGORY:=Network
  TITLE:=UCI configuration for offloaded switch features
  DEPENDS:=+ip-bridge +tc-full +kmod-sched-flower +kmod-sched-act-police
  PKGARCH:=all
endef

define Package/switchdev-config/description
  Applies static FDB entries, port mirroring and per-port rate limits from
  /etc/config/switchdev to switchdev ports, using bridge and tc rules that
  the switch offloads. Rules are added with skip_sw, so a setting the
  switch cannot offload is logged instead of being run by the CPU.
endef

define Package/switchdev-config/conffiles
/etc/config/switchdev
endef

define Build/Compile
endef

define Package/switchdev-config/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/switchdev.config $(1)/etc/config/switchdev
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/switchdev.init $(1)/etc/init.d/switchdev
endef

$(eval $(call BuildPackage,switchdev-config))
