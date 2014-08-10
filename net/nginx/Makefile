#
# Copyright (C) 2009-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nginx
PKG_VERSION:=1.4.7
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://nginx.org/download/
PKG_MD5SUM:=aee151d298dcbfeb88b3f7dd3e7a4d17
PKG_MAINTAINER:=Thomas Heil <heil@terminal-consulting.de>
PKG_LICENSE:=2-clause BSD-like license

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_CONFIG_DEPENDS := \
	CONFIG_NGINX_STUB_STATUS \
	CONFIG_NGINX_FLV \
	CONFIG_NGINX_SSL \
	CONFIG_NGINX_DAV \
	CONFIG_NGINX_LUA \
	CONFIG_NGINX_PCRE \
	CONFIG_NGINX_HTTP_CACHE \
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
	CONFIG_NGINX_HTTP_UPSTREAM_IP_HASH

include $(INCLUDE_DIR)/package.mk

define Package/nginx
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Nginx web server
  URL:=http://nginx.org/
  DEPENDS:=+NGINX_PCRE:libpcre +(NGINX_SSL||NGINX_HTTP_CACHE||NGINX_HTTP_AUTH_BASIC):libopenssl +NGINX_HTTP_GZIP:zlib +libpthread +NGINX_LUA:liblua
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
ifeq ($(CONFIG_NGINX_NAXSI),y)
  ADDITIONAL_MODULES += --add-module=$(PKG_BUILD_DIR)/nginx-naxsi/naxsi_src
endif
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
ifeq ($(CONFIG_NGINX_LUA),y)
  ADDITIONAL_MODULES += --add-module=$(PKG_BUILD_DIR)/lua-nginx
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
ifneq ($(CONFIG_NGINX_HTTP_UPSTREAM_IP_HASH),y)
  ADDITIONAL_MODULES += --without-http_upstream_ip_hash_module
endif
ifeq ($(CONFIG_NGINX_PROXYPROTOCOL),y)
  ADDITIONAL_MODULES += --with-proxy-protocol
endif
ifeq ($(CONFIG_NGINX_SYSLOG),y)
  ADDITIONAL_MODULES += --add-module=$(PKG_BUILD_DIR)/nginx-syslog
endif
ifeq ($(CONFIG_NGINX_HTTP_UPSTREAM_CHECK),y)
  ADDITIONAL_MODULES += --add-module=$(PKG_BUILD_DIR)/nginx-upstream-check
endif

define Build/Configure
	# TODO: fix --crossbuild
	(cd $(PKG_BUILD_DIR) ;\
		$(if $(CONFIG_NGINX_LUA),LUA_INC=$(STAGING_DIR)/usr/include LUA_LIB=$(STAGING_DIR)/usr/lib) \
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
			--with-ld-opt="$(TARGET_LDFLAGS)" )
endef

define Package/nginx/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/nginx $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/nginx
	$(INSTALL_DATA) $(addprefix $(PKG_INSTALL_DIR)/etc/nginx/,$(config_files)) $(1)/etc/nginx/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/nginx.init $(1)/etc/init.d/nginx
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	$(if $(CONFIG_NGINX_LUA),$(call Prepare/lua-nginx))
	$(if $(CONFIG_NGINX_NAXSI),$(call Prepare/nginx-naxsi))
	$(if $(CONFIG_NGINX_SYSLOG),$(call Prepare/nginx-syslog))
	$(if $(CONFIG_NGINX_HTTP_UPSTREAM_CHECK),$(call Prepare/nginx-upstream-check))
endef

define Download/lua-nginx
	VERSION:=d3ab0edd45bffe1b9a36abdf5bff544de436ccee
	SUBDIR:=lua-nginx
	FILE:=lua-nginx-module-$(PKG_VERSION)-$$(VERSION).tar.gz
	URL:=https://github.com/chaoslawful/lua-nginx-module.git
	PROTO:=git
endef

define  Prepare/lua-nginx
	$(eval $(call Download,lua-nginx))
	gzip -dc $(DL_DIR)/$(FILE) | tar -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)
	$(call PatchDir,$(PKG_BUILD_DIR),./patches-lua-nginx)
endef

define Download/nginx-upstream-check
	VERSION:=d40b9f956d9d978005bb15616d2f283d4e3d2031
	SUBDIR:=nginx-upstream-check
	FILE:=nginx-upstream-check-$(PKG_VERSION)-$$(VERSION).tar.gz
	URL:=https://github.com/yaoweibin/nginx_upstream_check_module.git
	PROTO:=git
endef

define  Prepare/nginx-upstream-check
	$(eval $(call Download,nginx-upstream-check))
	gzip -dc $(DL_DIR)/$(FILE) | tar -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)
	$(call PatchDir,$(PKG_BUILD_DIR),./patches-nginx-upstream-check)
endef


define Package/nginx-naxsi
        MENU:=1
        $(call Package/nginx)
        TITLE:=nginx-naxsi
        DEPENDS:=nginx @NGINX_NAXSI
endef

define Package/nginx-naxsi/description
        NGINX WAF NAXSI
endef

define Package/nginx-proxyprotocol
        MENU:=1
        $(call Package/nginx)
        TITLE:=nginx 
        DEPENDS:=nginx @NGINX_PROXYPROTOCOL
endef

define Package/nginx-proxyprotocol/description
        IMPLEMENT Proxy Protocol
endef

define Package/nginx-syslog
        MENU:=1
        $(call Package/nginx)
        TITLE:=nginx-syslog
        DEPENDS:=nginx @NGINX_SYSLOG
endef

define Package/nginx-syslog/description
        IMPLEMENT Syslog Protocol
endef

define Download/nginx-naxsi
	VERSION:=34dcb45fe4fdcb144c5258d83672f8e1e1c8db2e
	SUBDIR:=nginx-naxsi
	FILE:=nginx-naxsi-module-$(PKG_VERSION)-$$(VERSION).tar.gz
	URL:=https://github.com/nbs-system/naxsi.git
	PROTO:=git
endef

define  Prepare/nginx-naxsi
	$(eval $(call Download,nginx-naxsi))
	gzip -dc $(DL_DIR)/$(FILE) | tar -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)
endef

define Package/nginx-naxsi/install
	$(INSTALL_DIR) $(1)/etc/nginx
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nginx-naxsi/naxsi_config/naxsi_core.rules $(1)/etc/nginx
	chmod 0640 $(1)/etc/nginx/naxsi_core.rules
endef

define Download/nginx-syslog
	VERSION:=7abf48e52552c40a21463e1a8c608e0e575261cd
	SUBDIR:=nginx-syslog
	FILE:=nginx-syslog-module-$(PKG_VERSION)-$$(VERSION).tar.gz
	URL:=https://github.com/splitice/nginx_syslog_patch.git
	PROTO:=git
endef

define  Prepare/nginx-syslog
	$(eval $(call Download,nginx-syslog))
	gzip -dc $(DL_DIR)/$(FILE) | tar -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)
endef

define Package/nginx-proxyprotocol/install
	$(INSTALL_DIR) $(1)/etc/nginx
	$(INSTALL_BIN) ./files/nginx.proxyprotocol.example $(1)/etc/nginx/nginx.conf.proxyprotocol
	chmod 0640 $(1)/etc/nginx/nginx.conf.proxyprotocol
endef

define Package/nginx-syslog/install
	$(INSTALL_DIR) $(1)/etc/nginx
	$(INSTALL_BIN) ./files/nginx.syslog.example $(1)/etc/nginx/nginx.conf.syslog
	chmod 0640 $(1)/etc/nginx/nginx.conf.syslog
endef


$(eval $(call BuildPackage,nginx))
$(eval $(call BuildPackage,nginx-naxsi))
$(eval $(call BuildPackage,nginx-proxyprotocol))
$(eval $(call BuildPackage,nginx-syslog))

