#
# Copyright (C) 2016 Toke Høiland-Jørgensen
#
# This is free software, licensed under the GNU General Public License v3 or
# later.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=acme
PKG_VERSION:=2.7.8
PKG_RELEASE:=4
PKG_LICENSE:=GPLv3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Neilpang/acme.sh
PKG_SOURCE_VERSION:=521d8c4b1f374c52ab1452d399a4d4910465e9fe
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE).tar.xz
PKG_MIRROR_HASH:=03e24eb41513b4d28dc42f5ae5c91be0030094149cbdbf9cdf9b6f87db9e36c0
PKG_MAINTAINER:=Toke Høiland-Jørgensen <toke@toke.dk>

LUCI_DIR:=/usr/lib/lua/luci

include $(INCLUDE_DIR)/package.mk

define Package/acme
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+curl +ca-bundle +openssl-util +netcat
  TITLE:=ACME (Letsencrypt) client
endef

define Package/acme/description
 A client for issuing Letsencrypt certificates.
endef

define Package/acme/conffiles
/etc/config/acme
/etc/acme
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/acme/install
	$(INSTALL_DIR) $(1)/etc/acme
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/acme.config $(1)/etc/config/acme
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/acme.init $(1)/etc/init.d/acme
	$(INSTALL_DIR) $(1)/usr/lib/acme
	$(INSTALL_BIN) ./files/run.sh $(1)/usr/lib/acme/run-acme
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/acme.sh $(1)/usr/lib/acme/acme.sh
endef

define Package/acme-dnsapi
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+acme
  TITLE:=DNS API integration for ACME (Letsencrypt) client
endef

define Package/acme-dnsapi/description
 This package provides DNS API integration for ACME (Letsencrypt) client.
endef

define Package/acme-dnsapi/install
	$(INSTALL_DIR) $(1)/usr/lib/acme/dnsapi
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/dnsapi/*.sh $(1)/usr/lib/acme/dnsapi
endef

define Package/luci-app-acme
  SECTION:=luci
  CATEGORY:=LuCI
  TITLE:=ACME package - LuCI interface
  DEPENDS:= lua luci-base +acme luci-app-uhttpd
  SUBMENU:=3. Applications
endef

define Package/luci-app-acme/description
	Control the ACME Letsencrypt certificate interface
endef

define Package/luci-app-acme/install
	$(INSTALL_DIR) $(1)$(LUCI_DIR)/controller $(1)$(LUCI_DIR)/model/cbi
	$(INSTALL_DATA) ./files/acme-controller.lua $(1)$(LUCI_DIR)/controller/acme.lua
	$(INSTALL_DATA) ./files/acme-cbi.lua $(1)$(LUCI_DIR)/model/cbi/acme.lua
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/uci-defaults-acme $(1)/etc/uci-defaults/luci-acme
endef

define Package/luci-app-acme/postinst
#!/bin/sh
[ -x /etc/uci-defaults/luci-acme ] && /etc/uci-defaults/luci-acme || exit 0
endef

define Package/luci-app-acme/postrm
#!/bin/sh
which uci > /dev/null || exit 0
uci -q get ucitrack.@acme[0] > /dev/null && {
  uci delete ucitrack.@acme[0]
  uci commit
}
exit 0
endef


$(eval $(call BuildPackage,acme))
$(eval $(call BuildPackage,acme-dnsapi))
$(eval $(call BuildPackage,luci-app-acme))
