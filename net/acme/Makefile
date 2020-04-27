#
# Copyright (C) 2016 Toke Høiland-Jørgensen
#
# This is free software, licensed under the GNU General Public License v3 or
# later.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=acme
PKG_VERSION:=2.8.5
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Neilpang/acme.sh/tar.gz/$(PKG_VERSION)?
PKG_HASH:=45d964de8970096dae06aaa45dba2d9d09a41c0a43355191ee627eb00ba5db45
PKG_BUILD_DIR:=$(BUILD_DIR)/acme.sh-$(PKG_VERSION)

PKG_MAINTAINER:=Toke Høiland-Jørgensen <toke@toke.dk>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE.md

LUCI_DIR:=/usr/lib/lua/luci

include $(INCLUDE_DIR)/package.mk

define Package/acme
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+wget-ssl +ca-bundle +openssl-util +socat
  TITLE:=ACME (Letsencrypt) client
  URL:=https://acme.sh
  PKGARCH:=all
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
  PKGARCH:=all
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
  DEPENDS:= lua luci-base luci-compat +acme
  SUBMENU:=3. Applications
  PKGARCH:=all
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
