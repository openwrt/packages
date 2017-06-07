#
# Copyright (C) 2012-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-shadowsocks-spec
PKG_VERSION:=1.3.2
PKG_RELEASE:=1

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=aa65535 <aa65535@live.com>

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-shadowsocks-spec/Default
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=shadowsocks-libev-spec LuCI interface
	DEPENDS:=+luci-mod-admin-full $(1)
endef

Package/luci-app-shadowsocks-spec = $(call Package/luci-app-shadowsocks-spec/Default,shadowsocks-libev-spec)
Package/luci-app-shadowsocks-spec-polarssl = $(call Package/luci-app-shadowsocks-spec/Default,shadowsocks-libev-spec-polarssl)

define Package/luci-app-shadowsocks-spec/description
	LuCI Support for shadowsocks-libev-spec.
endef

define Package/luci-app-shadowsocks-spec-polarssl/description
	LuCI Support for shadowsocks-libev-spec-polarssl.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-shadowsocks-spec/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	( . /etc/uci-defaults/luci-shadowsocks ) && rm -f /etc/uci-defaults/luci-shadowsocks
	chmod 755 /etc/init.d/shadowsocks >/dev/null 2>&1
	/etc/init.d/shadowsocks enable >/dev/null 2>&1
fi
exit 0
endef

Package/luci-app-shadowsocks-spec-polarssl/postinst = $(Package/luci-app-shadowsocks-spec/postinst)

define Package/luci-app-shadowsocks-spec/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/shadowsocks-controller.lua $(1)/usr/lib/lua/luci/controller/shadowsocks.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) ./files/shadowsocks.*.lmo $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./files/shadowsocks-cbi.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks.lua
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/shadowsocks-uci-defaults $(1)/etc/uci-defaults/luci-shadowsocks
endef

Package/luci-app-shadowsocks-spec-polarssl/install = $(Package/luci-app-shadowsocks-spec/install)

$(eval $(call BuildPackage,luci-app-shadowsocks-spec))
$(eval $(call BuildPackage,luci-app-shadowsocks-spec-polarssl))
