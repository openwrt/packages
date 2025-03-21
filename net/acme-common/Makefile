#
# Copyright (C) 2016 Toke Høiland-Jørgensen
#
# This is free software, licensed under the GNU General Public License v3 or
# later.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=acme-common
PKG_VERSION:=1.4.4

PKG_MAINTAINER:=Toke Høiland-Jørgensen <toke@toke.dk>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE.md

include $(INCLUDE_DIR)/package.mk

define Package/acme-common
  SECTION:=net
  CATEGORY:=Network
  TITLE:=ACME client wrapper common files
  PKGARCH:=all
endef

define Package/acme-common/description
ACME client wrapper common files.
endef

define Package/acme-common/conffiles
/etc/config/acme
/etc/acme
/etc/ssl/acme
endef

define Package/acme-common/install
	$(INSTALL_DIR) $(1)/etc/acme
	$(INSTALL_DIR) $(1)/etc/ssl/acme
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/acme.config $(1)/etc/config/acme
	$(INSTALL_DIR) $(1)/usr/lib/acme
	$(INSTALL_DATA) ./files/functions.sh $(1)/usr/lib/acme
	$(INSTALL_BIN) ./files/acme-notify.sh $(1)/usr/lib/acme/notify
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/acme.init $(1)/etc/init.d/acme
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DATA) ./files/acme.uci-defaults $(1)/etc/uci-defaults/acme
	$(INSTALL_DIR) $(1)/etc/hotplug.d/acme
endef

define Package/acme-common/prerm
#!/bin/sh
sed -i '\|/etc/init.d/acme|d' /etc/crontabs/root
endef

define Build/Configure
endef

define Build/Compile
endef

$(eval $(call BuildPackage,acme-common))
