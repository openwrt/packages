#
# Copyright (C) 2016 Toke Høiland-Jørgensen
#
# This is free software, licensed under the GNU General Public License v3 or
# later.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=acme
PKG_VERSION:=2.7.9
PKG_RELEASE:=8
PKG_LICENSE:=GPLv3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Neilpang/acme.sh/tar.gz/$(PKG_VERSION)?
PKG_HASH:=25f8eef1a53584e3ebc653e1ae7763362ca97c40bb476ab7fee01aa50fa3a101
PKG_BUILD_DIR:=$(BUILD_DIR)/acme.sh-$(PKG_VERSION)
PKG_MAINTAINER:=Toke Høiland-Jørgensen <toke@toke.dk>
PKGARCH:=all

LUCI_DIR:=/usr/lib/lua/luci

include $(INCLUDE_DIR)/package.mk

define Package/acme
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+curl +ca-bundle +openssl-util +socat
  TITLE:=ACME (Letsencrypt) client
endef

define Package/acme/description
 A client for issuing Letsencrypt certificates.
endef

define Package/acme/conffiles
/etc/config/acme
/etc/acme
endef

define Build/Prepare
	$(foreach po,$(wildcard ${CURDIR}/files/luci/i18n/*.po), \
		po2lmo $(po) $(PKG_BUILD_DIR)/$(patsubst %.po,%.lmo,$(notdir $(po)));)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/acme/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/root/etc/config/acme $(1)/etc/config/acme
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/root/etc/init.d/acme $(1)/etc/init.d/acme
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/root/etc/uci-defaults/luci-acme $(1)/etc/uci-defaults/luci-acme
	$(INSTALL_DIR) $(1)/usr/lib/acme
	$(INSTALL_BIN) ./files/root/usr/lib/acme/run-acme $(1)/usr/lib/acme/run-acme
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
  DEPENDS:= lua luci-base +acme
  SUBMENU:=3. Applications
endef

define Package/luci-app-acme/description
	Control the ACME Letsencrypt certificate interface
endef

define Package/luci-app-acme/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/acme.*.lmo $(1)/usr/lib/lua/luci/i18n/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/luci/controller/*.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/acme
	$(INSTALL_DATA) ./files/luci/model/cbi/*.lua $(1)/usr/lib/lua/luci/model/cbi/
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
