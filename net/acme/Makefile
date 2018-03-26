#
# Copyright (C) 2016 Toke Høiland-Jørgensen
#
# This is free software, licensed under the GNU General Public License v3 or
# later.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=acme
PKG_SOURCE_VERSION:=db3264ab8c8ee1aee1a84407702db4375f67765b
PKG_VERSION:=1.6
PKG_RELEASE:=4
PKG_LICENSE:=GPLv3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE).tar.xz
PKG_MIRROR_HASH:=a881b86fef2b754739fc0024efdf061312fecaf613502434770b18191bda741d
PKG_SOURCE_URL:=git://github.com/Neilpang/acme.sh.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)
LUCI_DIR:=/usr/lib/lua/luci

include $(INCLUDE_DIR)/package.mk

define Package/acme
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+curl +ca-bundle +openssl-util +netcat
  TITLE:=ACME (Letsencrypt) client
  PKGARCH:=all
  MAINTAINER:=Toke Høiland-Jørgensen <toke@toke.dk>
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

define Package/luci-app-acme
  SECTION:=luci
  CATEGORY:=LuCI
  TITLE:=ACME package - LuCI interface
  MAINTAINER:=Toke Høiland-Jørgensen <toke@toke.dk>
  PKGARCH:=all
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
$(eval $(call BuildPackage,luci-app-acme))
