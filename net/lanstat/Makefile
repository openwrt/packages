# SPDX-License-Identifier: MIT

include $(TOPDIR)/rules.mk

PKG_NAME:=lanstat
PKG_VERSION:=1.0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/wbpluto/lanstat/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=5bd75ec0ca1c0217885337919e989e63f945b0c4c37b7a37224a23dac6c27174

PKG_MAINTAINER:=Junwei Huang <hjw@live.cn>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/lanstat
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Monitoring
  TITLE:=Lightweight native LAN bandwidth monitor with modern Web UI
  URL:=https://github.com/wbpluto/lanstat
endef

define Package/lanstat/description
  A lightweight, single-binary C11 packet & bandwidth monitor for OpenWrt.
  Uses AF_PACKET + TPACKET_V2 zero-copy ring buffer and serves a built-in
  gzip-compressed real-time Mbps dashboard with offline IEEE OUI vendor lookup
  and multi-language UI without external runtime dependencies.
endef

define Package/lanstat/conffiles
/etc/config/lanstat
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) -std=c11 -Wall -Wextra -I$(PKG_BUILD_DIR)/src \
		$(PKG_BUILD_DIR)/src/main.c \
		$(PKG_BUILD_DIR)/src/hosts.c \
		$(PKG_BUILD_DIR)/src/capture.c \
		$(PKG_BUILD_DIR)/src/http.c \
		-o $(PKG_BUILD_DIR)/lanstat $(TARGET_LDFLAGS)
endef

define Package/lanstat/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lanstat $(1)/usr/sbin/lanstat
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/lanstat.config $(1)/etc/config/lanstat
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/lanstat.init $(1)/etc/init.d/lanstat
	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/openwrt/usr/share/luci/menu.d/lanstat.json $(1)/usr/share/luci/menu.d/lanstat.json
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/openwrt/usr/share/rpcd/acl.d/lanstat.json $(1)/usr/share/rpcd/acl.d/lanstat.json
	$(INSTALL_DIR) $(1)/www/luci-static/resources/view
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/openwrt/www/luci-static/resources/view/lanstat.js $(1)/www/luci-static/resources/view/lanstat.js
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/openwrt/usr/lib/lua/luci/i18n/lanstat.zh-cn.lmo $(1)/usr/lib/lua/luci/i18n/lanstat.zh-cn.lmo
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/openwrt/usr/lib/lua/luci/i18n/lanstat.zh-tw.lmo $(1)/usr/lib/lua/luci/i18n/lanstat.zh-tw.lmo
endef

define Package/lanstat/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	rm -f /tmp/luci-indexcache*
	rm -rf /tmp/luci-modulecache/*
	[ -x /etc/init.d/rpcd ] && /etc/init.d/rpcd reload >/dev/null 2>&1 || true
}
exit 0
endef

define Package/lanstat/postrm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	rm -f /tmp/luci-indexcache*
	rm -rf /tmp/luci-modulecache/*
	[ -x /etc/init.d/rpcd ] && /etc/init.d/rpcd reload >/dev/null 2>&1 || true
}
exit 0
endef

$(eval $(call BuildPackage,lanstat))
