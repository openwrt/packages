#
# Copyright (C) 2012-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nginx
PKG_VERSION:=1.9.6
PKG_RELEASE:=1

PKG_SOURCE:=nginx-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://nginx.org/download/
PKG_MD5SUM:=f6899825e7a8deadba4948ff84515ad6
PKG_MAINTAINER:=Thomas Heil <heil@terminal-consulting.de>
PKG_LICENSE:=2-clause BSD-like license

PKG_BUILD_DIR:=$(BUILD_DIR)/nginx-$(PKG_VERSION)

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_CONFIG_DEPENDS := \
	CONFIG_NGINX_SSL \
	CONFIG_NGINX_DAV \
	CONFIG_NGINX_FLV \
	CONFIG_NGINX_STUB_STATUS \
	CONFIG_NGINX_HTTP_CHARSET \
	CONFIG_NGINX_HTTP_GZIP \
	CONFIG_NGINX_HTTP_SSI \
	CONFIG_NGINX_HTTP_USERID \
	CONFIG_NGINX_HTTP_ACCESS \
	CONFIG_NGINX_HTTP_AUTH_BASIC \
	CONFIG_NGINX_HTTP_AUTOINDEX \
	CONFIG_NGINX_HTTP_GEO \
	CONFIG_NGINX_HTTP_MAP \
	CONFIG_NGINX_HTTP_SPLIT_CLIENTS \
	CONFIG_NGINX_HTTP_REFERER \
	CONFIG_NGINX_HTTP_REWRITE \
	CONFIG_NGINX_HTTP_PROXY \
	CONFIG_NGINX_HTTP_FASTCGI \
	CONFIG_NGINX_HTTP_UWSGI \
	CONFIG_NGINX_HTTP_SCGI \
	CONFIG_NGINX_HTTP_MEMCACHED \
	CONFIG_NGINX_HTTP_LIMIT_CONN \
	CONFIG_NGINX_HTTP_LIMIT_REQ \
	CONFIG_NGINX_HTTP_EMPTY_GIF \
	CONFIG_NGINX_HTTP_BROWSER \
	CONFIG_NGINX_HTTP_UPSTREAM_HASH \
	CONFIG_NGINX_HTTP_UPSTREAM_IP_HASH \
	CONFIG_NGINX_HTTP_UPSTREAM_LEAST_CONN \
	CONFIG_NGINX_HTTP_UPSTREAM_KEEPALIVE \
	CONFIG_NGINX_HTTP_UPSTREAM_ZONE \
	CONFIG_NGINX_HTTP_CACHE \
	CONFIG_NGINX_PCRE

include $(INCLUDE_DIR)/package.mk

define Package/nginx
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Nginx web server
  URL:=http://nginx.org/
  DEPENDS:=+NGINX_PCRE:libpcre +(NGINX_SSL||NGINX_HTTP_CACHE||NGINX_HTTP_AUTH_BASIC):libopenssl +NGINX_HTTP_GZIP:zlib +libpthread
  MENU:=1
endef

define Package/nginx/description
 nginx is an HTTP and reverse proxy server, as well as a mail proxy server,
 written by Igor Sysoev.
endef

define Package/nginx/config
  source "$(SOURCE)/Config.in"
endef

config_files=nginx.conf mime.types fastcgi_params koi-utf koi-win win-utf

define Package/nginx/conffiles
/etc/nginx/
endef

ADDITIONAL_MODULES:=
ifeq ($(CONFIG_IPV6),y)
  ADDITIONAL_MODULES += --with-ipv6
endif
ifeq ($(CONFIG_NGINX_STUB_STATUS),y)
  ADDITIONAL_MODULES += --with-http_stub_status_module
endif
ifeq ($(CONFIG_NGINX_FLV),y)
  ADDITIONAL_MODULES += --with-http_flv_module
endif
ifeq ($(CONFIG_NGINX_SSL),y)
  ADDITIONAL_MODULES += --with-http_ssl_module
endif
ifeq ($(CONFIG_NGINX_DAV),y)
  ADDITIONAL_MODULES += --with-http_dav_module
endif
ifneq ($(CONFIG_NGINX_HTTP_CACHE),y)
  ADDITIONAL_MODULES += --without-http-cache
endif
ifneq ($(CONFIG_NGINX_PCRE),y)
  ADDITIONAL_MODULES += --without-pcre
endif
ifneq ($(CONFIG_NGINX_HTTP_CHARSET),y)
  ADDITIONAL_MODULES += --without-http_charset_module
endif
ifneq ($(CONFIG_NGINX_HTTP_GZIP),y)
  ADDITIONAL_MODULES += --without-http_gzip_module
endif
ifneq ($(CONFIG_NGINX_HTTP_SSI),y)
  ADDITIONAL_MODULES += --without-http_ssi_module
endif
ifneq ($(CONFIG_NGINX_HTTP_USERID),y)
  ADDITIONAL_MODULES += --without-http_userid_module
endif
ifneq ($(CONFIG_NGINX_HTTP_ACCESS),y)
  ADDITIONAL_MODULES += --without-http_access_module
endif
ifneq ($(CONFIG_NGINX_HTTP_AUTH_BASIC),y)
  ADDITIONAL_MODULES += --without-http_auth_basic_module
endif
ifneq ($(CONFIG_NGINX_HTTP_AUTOINDEX),y)
  ADDITIONAL_MODULES += --without-http_autoindex_module
endif
ifneq ($(CONFIG_NGINX_HTTP_GEO),y)
  ADDITIONAL_MODULES += --without-http_geo_module
endif
ifneq ($(CONFIG_NGINX_HTTP_MAP),y)
  ADDITIONAL_MODULES += --without-http_map_module
endif
ifneq ($(CONFIG_NGINX_HTTP_SPLIT_CLIENTS),y)
  ADDITIONAL_MODULES += --without-http_split_clients_module
endif
ifneq ($(CONFIG_NGINX_HTTP_REFERER),y)
  ADDITIONAL_MODULES += --without-http_referer_module
endif
ifneq ($(CONFIG_NGINX_HTTP_REWRITE),y)
  ADDITIONAL_MODULES += --without-http_rewrite_module
endif
ifneq ($(CONFIG_NGINX_HTTP_PROXY),y)
  ADDITIONAL_MODULES += --without-http_proxy_module
endif
ifneq ($(CONFIG_NGINX_HTTP_FASTCGI),y)
  ADDITIONAL_MODULES += --without-http_fastcgi_module
endif
ifneq ($(CONFIG_NGINX_HTTP_UWSGI),y)
  ADDITIONAL_MODULES += --without-http_uwsgi_module
endif
ifneq ($(CONFIG_NGINX_HTTP_SCGI),y)
  ADDITIONAL_MODULES += --without-http_scgi_module
endif
ifneq ($(CONFIG_NGINX_HTTP_MEMCACHED),y)
  ADDITIONAL_MODULES += --without-http_memcached_module
endif
ifneq ($(CONFIG_NGINX_HTTP_LIMIT_CONN),y)
  ADDITIONAL_MODULES += --without-http_limit_conn_module
endif
ifneq ($(CONFIG_NGINX_HTTP_LIMIT_REQ),y)
  ADDITIONAL_MODULES += --without-http_limit_req_module
endif
ifneq ($(CONFIG_NGINX_HTTP_EMPTY_GIF),y)
  ADDITIONAL_MODULES += --without-http_empty_gif_module
endif
ifneq ($(CONFIG_NGINX_HTTP_BROWSER),y)
  ADDITIONAL_MODULES += --without-http_browser_module
endif
ifneq ($(CONFIG_NGINX_HTTP_UPSTREAM_HASH),y)
  ADDITIONAL_MODULES += --without-http_upstream_hash_module
endif
ifneq ($(CONFIG_NGINX_HTTP_UPSTREAM_IP_HASH),y)
  ADDITIONAL_MODULES += --without-http_upstream_ip_hash_module
endif
ifneq ($(CONFIG_NGINX_HTTP_UPSTREAM_LEAST_CONN),y)
  ADDITIONAL_MODULES += --without-http_upstream_least_conn_module
endif
ifneq ($(CONFIG_NGINX_HTTP_UPSTREAM_KEEPALIVE),y)
  ADDITIONAL_MODULES += --without-http_upstream_keepalive_module
endif

define Build/Configure
	( cd $(PKG_BUILD_DIR) ; \
		./configure \
			--crossbuild=Linux::$(ARCH) \
			--prefix=/usr \
			--conf-path=/etc/nginx/nginx.conf \
			$(ADDITIONAL_MODULES) \
			--error-log-path=/var/log/nginx/error.log \
			--pid-path=/var/run/nginx.pid \
			--lock-path=/var/lock/nginx.lock \
			--http-log-path=/var/log/nginx/access.log \
			--http-client-body-temp-path=/var/lib/nginx/body \
			--http-proxy-temp-path=/var/lib/nginx/proxy \
			--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
			--with-cc="$(TARGET_CC)" \
			--with-cc-opt="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS)" \
			--with-ld-opt="$(TARGET_LDFLAGS)" \
			--without-http_upstream_zone_module \
	)
endef

define Package/nginx/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/nginx $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/nginx
	$(INSTALL_DATA) $(addprefix $(PKG_INSTALL_DIR)/etc/nginx/,$(config_files)) $(1)/etc/nginx/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/nginx.init $(1)/etc/init.d/nginx
endef

$(eval $(call BuildPackage,nginx))
