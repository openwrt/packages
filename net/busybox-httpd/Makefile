#
# Copyright (C) 2007-2021 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=busybox-httpd
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Sergey Ponomarev <stokito@gmail.com>
PKG_LICENSE:=ISC

include $(INCLUDE_DIR)/package.mk

# The BB httpd needs to be first enabled for compilation CONFIG_BUSYBOX_CONFIG_HTTPD=y.
# Using `make menuconfig`:
# Base System / Customize Busybox options / Network utilities / httpd
#   Support Common Gateway Interface (CGI)
#   Set REMOTE_PORT environment variable for CGI
#   Recommended: Support 'Ranges:' header
#   Recommended: Add Last-Modified header to response
#   Recommended: Enable HTTP authentication
# Note that it conflicts with uhttpd so disable it: `uci set uhttpd.main.enabled=0; uci commit`
define Package/busybox-httpd
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=BusyBox HTTP server
  URL:=https://openwrt.org/docs/guide-user/services/webserver/http.httpd
  DEPENDS:=@BUSYBOX_CONFIG_HTTPD
  PKGARCH:=all
endef

define Package/busybox-httpd/description
  A service package to run BusyBox HTTP daemon.
endef

define Package/busybox-httpd/conffiles
/etc/httpd.conf
/etc/config/httpd
endef

define Build/Compile
endef

define Package/busybox-httpd/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/busybox-httpd $(1)/etc/init.d/busybox-httpd

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/httpd $(1)/etc/config/httpd
endef

$(eval $(call BuildPackage,busybox-httpd))
