#
# Copyright (C) 2012-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nginx
PKG_VERSION:=1.25.0
PKG_RELEASE:=4

PKG_SOURCE:=nginx-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://nginx.org/download/
PKG_HASH:=5ed44d45943272a4e8a5bcf4434237210f2de31b903fca5e381c1bbd7eee1e8c

PKG_MAINTAINER:=Thomas Heil <heil@terminal-consulting.de> \
				Ansuel Smith <ansuelsmth@gmail.com>
PKG_LICENSE:=2-clause BSD-like license
PKG_CPE_ID:=cpe:/a:nginx:nginx

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_BUILD_FLAGS:=gc-sections

PKG_CONFIG_DEPENDS := \
	CONFIG_NGINX_DAV \
	CONFIG_NGINX_FLV \
	CONFIG_NGINX_STUB_STATUS \
	CONFIG_NGINX_HTTP_CHARSET \
	CONFIG_NGINX_HTTP_GZIP \
	CONFIG_NGINX_HTTP_GZIP_STATIC \
	CONFIG_NGINX_HTTP_SSI \
	CONFIG_NGINX_HTTP_USERID \
	CONFIG_NGINX_HTTP_ACCESS \
	CONFIG_NGINX_HTTP_AUTH_BASIC \
	CONFIG_NGINX_HTTP_AUTH_REQUEST \
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
	CONFIG_NGINX_HTTP_V2 \
	CONFIG_NGINX_PCRE \
	CONFIG_NGINX_HTTP_REAL_IP \
	CONFIG_NGINX_HTTP_SECURE_LINK \
	CONFIG_OPENSSL_ENGINE \
	CONFIG_OPENSSL_WITH_NPN

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/nginx/default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Nginx web server
  URL:=http://nginx.org/
  DEPENDS:=+libopenssl +libpthread
  # TODO: add PROVIDES when removing nginx
  # PROVIDES:=nginx
endef

define Package/nginx/description
 nginx is an HTTP and reverse proxy server, as well as a mail proxy server, \
 written by Igor Sysoev.
endef

define Package/nginx-ssl
  $(Package/nginx/default)
  TITLE += with SSL support
  VARIANT:=ssl
  DEPENDS+= +NGINX_PCRE:libpcre \
	+NGINX_PCRE:nginx-ssl-util +!NGINX_PCRE:nginx-ssl-util-nopcre \
	+NGINX_HTTP_GZIP:zlib +NGINX_DAV:libxml2
  EXTRA_DEPENDS:=nginx-ssl-util$(if $(CONFIG_NGINX_PCRE),,-nopcre) (>=1.5-1) (<2)
  CONFLICTS:=nginx-full
endef

Package/nginx-ssl/description = $(Package/nginx/description) \
  This variant is compiled with SSL support enabled. To enable additional module \
  select them in the nginx default configuration menu.

define Package/nginx-full
  $(Package/nginx/default)
  TITLE += with ALL module selected
  DEPENDS+=+libpcre +nginx-ssl-util +zlib +libxml2
  EXTRA_DEPENDS:=nginx-ssl-util (>=1.5-1) (<2)
  VARIANT:=all-module
  PROVIDES += nginx-ssl
endef

Package/nginx-full/description = $(Package/nginx/description) \
  This variant is compiled with ALL module selected.

define Package/nginx-ssl/config
  source "$(SOURCE)/Config_ssl.in"
endef

config_files=mime.types

define Package/nginx/conffiles
/etc/nginx/
endef

Package/nginx-ssl/conffiles = $(Package/nginx/conffiles)
Package/nginx-full/conffiles = $(Package/nginx/conffiles)

ADDITIONAL_MODULES:= --with-http_ssl_module

ifneq ($(BUILD_VARIANT),all-module)
  ifneq ($(CONFIG_NGINX_HTTP_CACHE),y)
    ADDITIONAL_MODULES += --without-http-cache
  endif
  ifneq ($(CONFIG_NGINX_PCRE),y)
    ADDITIONAL_MODULES += --without-pcre
  endif
  ifneq ($(CONFIG_NGINX_HTTP_CHARSET),y)
    ADDITIONAL_MODULES += --without-http_charset_module
  else
    config_files += koi-utf koi-win win-utf
  endif
  ifneq ($(CONFIG_NGINX_HTTP_GZIP),y)
    ADDITIONAL_MODULES += --without-http_gzip_module
  endif
  ifeq ($(CONFIG_NGINX_HTTP_GZIP_STATIC),y)
    ADDITIONAL_MODULES += --with-http_gzip_static_module
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
  else
    config_files += fastcgi_params
  endif
  ifneq ($(CONFIG_NGINX_HTTP_UWSGI),y)
    ADDITIONAL_MODULES += --without-http_uwsgi_module
  else
    config_files += uwsgi_params
  endif
  ifneq ($(CONFIG_NGINX_HTTP_SCGI),y)
    ADDITIONAL_MODULES += --without-http_scgi_module
  else
    config_files += scgi_params
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
  ifeq ($(CONFIG_IPV6),y)
    ADDITIONAL_MODULES += --with-ipv6
  endif
  ifeq ($(CONFIG_NGINX_STUB_STATUS),y)
    ADDITIONAL_MODULES += --with-http_stub_status_module
  endif
  ifeq ($(CONFIG_NGINX_FLV),y)
    ADDITIONAL_MODULES += --with-http_flv_module
  endif
  ifeq ($(CONFIG_NGINX_DAV),y)
    ADDITIONAL_MODULES += --with-http_dav_module
  endif
  ifeq ($(CONFIG_NGINX_HTTP_AUTH_REQUEST),y)
    ADDITIONAL_MODULES += --with-http_auth_request_module
  endif
  ifeq ($(CONFIG_NGINX_HTTP_V2),y)
    ADDITIONAL_MODULES += --with-http_v2_module
  endif
  ifeq ($(CONFIG_NGINX_HTTP_REAL_IP),y)
    ADDITIONAL_MODULES += --with-http_realip_module
  endif
  ifeq ($(CONFIG_NGINX_HTTP_SECURE_LINK),y)
    ADDITIONAL_MODULES += --with-http_secure_link_module
  endif
  ifeq ($(CONFIG_NGINX_HTTP_SUB),y)
	ADDITIONAL_MODULES += --with-http_sub_module
  endif
else
  ADDITIONAL_MODULES += --with-ipv6 --with-http_stub_status_module --with-http_flv_module \
	--with-http_dav_module \
	--with-http_auth_request_module --with-http_v2_module --with-http_realip_module \
	--with-http_secure_link_module --with-http_sub_module
  config_files += koi-utf koi-win win-utf fastcgi_params uwsgi_params
endif

ifneq ($(CONFIG_PACKAGE_nginx-mod-naxsi),)
  ADDITIONAL_MODULES += --add-dynamic-module=$(PKG_BUILD_DIR)/nginx-naxsi/naxsi_src
endif
ifneq ($(CONFIG_PACKAGE_nginx-mod-lua),)
  ADDITIONAL_MODULES += --add-dynamic-module=$(PKG_BUILD_DIR)/lua-nginx
endif
ifneq ($(CONFIG_PACKAGE_nginx-mod-dav-ext),)
  ADDITIONAL_MODULES += --add-dynamic-module=$(PKG_BUILD_DIR)/nginx-dav-ext-module
endif
ifneq ($(CONFIG_PACKAGE_nginx-mod-stream),)
  ADDITIONAL_MODULES += --with-stream=dynamic --with-stream_ssl_module --with-stream_ssl_preread_module
endif
ifneq ($(CONFIG_PACKAGE_nginx-mod-ubus),)
  ADDITIONAL_MODULES += --add-dynamic-module=$(PKG_BUILD_DIR)/nginx-ubus-module
endif
ifneq ($(CONFIG_PACKAGE_nginx-mod-headers-more),)
  ADDITIONAL_MODULES += --add-dynamic-module=$(PKG_BUILD_DIR)/nginx-headers-more
endif
ifneq ($(CONFIG_PACKAGE_nginx-mod-brotli),)
  ADDITIONAL_MODULES += --add-dynamic-module=$(PKG_BUILD_DIR)/nginx-brotli
endif
ifneq ($(CONFIG_PACKAGE_nginx-mod-rtmp),)
  ADDITIONAL_MODULES += --add-dynamic-module=$(PKG_BUILD_DIR)/nginx-rtmp
endif
ifneq ($(CONFIG_PACKAGE_nginx-mod-ts),)
  ADDITIONAL_MODULES += --add-dynamic-module=$(PKG_BUILD_DIR)/nginx-ts
endif
ifeq ($(CONFIG_NGINX_GEOIP_MODULE),y)
  ADDITIONAL_MODULES += --with-http_geoip_module=dynamic
endif

define Package/nginx-mod-luci
  TITLE:=Nginx on LuCI
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Support file for Nginx
  URL:=http://nginx.org/
  DEPENDS:=+uwsgi +uwsgi-luci-support +nginx +nginx-mod-ubus
  # TODO: add PROVIDES when removing nginx-mod-luci-ssl
  # PROVIDES:=nginx-mod-luci-ssl
endef

define Package/nginx-mod-luci/description
 Support file for LuCI in nginx. Include custom nginx configuration, autostart script for uwsgi.
endef

NGINX_MODULES :=

# $(1) module name
# $(2) module additional dependency
# $(3) module so name (stripped of the finaly _module.so)
# $(4) module description
define module
  define Package/nginx-mod-$(strip $(1))
	$(call Package/nginx/default)
	DEPENDS:=+nginx-ssl $(2)
	TITLE:=Nginx $(1) module
  endef

  define Package/nginx-mod-$(strip $(1))/description
   $(4)
  endef

  define Package/nginx-mod-$(strip $(1))/install
	$(INSTALL_DIR) $$(1)/usr/lib/nginx/modules
	$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/lib/nginx/modules/$(3)_module.so $$(1)/usr/lib/nginx/modules
  endef

  NGINX_MODULES += nginx-mod-$(strip $(1))
endef

define brotli
  define Package/nginx-mod-brotli
	$(call Package/nginx/default)
	DEPENDS:=+nginx-ssl
	TITLE:=Nginx Brotli module
  endef

  define Package/nginx-mod-brotli/description
   Add support for brotli compression module.
  endef

  define Package/nginx-mod-brotli/install
	$(INSTALL_DIR) $$(1)/usr/lib/nginx/modules
	$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/lib/nginx/modules/ngx_http_brotli_filter_module.so $$(1)/usr/lib/nginx/modules
	$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/lib/nginx/modules/ngx_http_brotli_static_module.so $$(1)/usr/lib/nginx/modules
  endef

  NGINX_MODULES += nginx-mod-brotli
endef

define naxsi
  define Package/nginx-mod-naxsi
	$(call Package/nginx/default)
	DEPENDS:=+nginx-ssl
	TITLE:=Nginx naxsi module
  endef

  define Package/nginx-mod-naxsi/description
   Enable NAXSI module.
  endef

  define Package/nginx-mod-naxsi/install
	$(INSTALL_DIR) $$(1)/usr/lib/nginx/modules
	$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/lib/nginx/modules/ngx_http_naxsi_module.so $$(1)/usr/lib/nginx/modules

	$(INSTALL_DIR) $$(1)/etc/nginx
	$(INSTALL_BIN) $$(PKG_BUILD_DIR)/nginx-naxsi/naxsi_config/naxsi_core.rules $$(1)/etc/nginx
	chmod 0640 $$(1)/etc/nginx/naxsi_core.rules

	$(INSTALL_BIN) $$(PKG_BUILD_DIR)/nginx-naxsi/naxsi_config/naxsi_core.rules $$(1)/etc/nginx
	chmod 0640 $$(1)/etc/nginx/naxsi_core.rules
  endef

  NGINX_MODULES += nginx-mod-naxsi
endef

$(eval $(call module,lua, +luajit,ngx_http_lua, Enable Lua module))
$(eval $(call module,stream, +@NGINX_STREAM_CORE_MODULE,ngx_stream, Add support for NGINX request streaming.))
$(eval $(call module,ubus, +libubus +libjson-c +libblobmsg-json +@NGINX_UBUS,ngx_http_ubus, Enable UBUS api support directly from the server.))
$(eval $(call module,dav-ext, +@NGINX_DAV +libxml2,ngx_http_dav_ext, Enable the WebDAV methods PROPFIND OPTIONS LOCK UNLOCK.))
$(eval $(call module,headers-more,,ngx_http_headers_more_filter, Set and clear input and output headers...more than "add"!))
$(eval $(call module,rtmp,,ngx_rtmp, Add support for NGINX-based Media Streaming Server module. \
		DASH enhanced - https://github.com/ut0mt8/nginx-rtmp-module))
$(eval $(call module, ts,,ngx_http_ts, Add support for MPEG-TS Live Module module.))
$(eval $(call brotli))
$(eval $(call naxsi))

PKG_CONFIG_DEPENDS += $(patsubst %,CONFIG_PACKAGE_%,$(NGINX_MODULES))

TARGET_CFLAGS += -DNGX_LUA_NO_BY_LUA_BLOCK

ifneq ($(CONFIG_PACKAGE_nginx-mod-lua),)
  CONFIGURE_VARS += LUAJIT_INC=$(STAGING_DIR)/usr/include/luajit-* \
					LUAJIT_LIB=$(STAGING_DIR)/usr/lib
endif

CONFIGURE_VARS += CONFIG_BIG_ENDIAN=$(CONFIG_BIG_ENDIAN)

CONFIGURE_ARGS += \
			--crossbuild=Linux::$(ARCH) \
			--prefix=/usr \
			--conf-path=/etc/nginx/nginx.conf \
			--modules-path=/usr/lib/nginx/modules \
			--with-compat \
			$(ADDITIONAL_MODULES) \
			--error-log-path=stderr \
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
			--without-pcre2

define Package/nginx-mod-luci/install
	$(INSTALL_DIR) $(1)/etc/nginx/conf.d
	$(INSTALL_CONF) ./files-luci-support/luci.locations $(1)/etc/nginx/conf.d/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files-luci-support/60_nginx-luci-support $(1)/etc/uci-defaults/60_nginx-luci-support
endef

define Package/nginx-ssl/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/nginx $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/nginx/module.d
	$(INSTALL_DIR) $(1)/etc/nginx/conf.d
	$(INSTALL_DATA) $(addprefix $(PKG_INSTALL_DIR)/etc/nginx/,$(config_files)) $(1)/etc/nginx/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/nginx.init $(1)/etc/init.d/nginx
endef

Package/nginx-full/install = $(Package/nginx-ssl/install)

define Package/nginx-ssl/prerm
#!/bin/sh
[ -z "$${IPKG_INSTROOT}" ] || exit 0
[ "$${PKG_UPGRADE}" = "1" ] && exit 0
eval $$(/usr/bin/nginx-util get_env)
[ "$$(uci get "nginx.$${LAN_NAME}.$${MANAGE_SSL}")" = "self-signed" ] || exit 0
rm -f "$$(uci get "nginx.$${LAN_NAME}.ssl_certificate")"
rm -f "$$(uci get "nginx.$${LAN_NAME}.ssl_certificate_key")"
exit 0
endef

Package/nginx-full/prerm = $(Package/nginx-ssl/prerm)

define Download/nginx-headers-more
  VERSION:=bea1be3bbf6af28f6aa8cf0c01c07ee1637e2bd0
  SUBDIR:=nginx-headers-more
  FILE:=headers-more-nginx-module-$$(VERSION).tar.xz
  URL:=https://github.com/openresty/headers-more-nginx-module.git
  MIRROR_HASH:=3617bbf7a935208a1d8d5f86a8f9b770f6987e4d2b5663a9ab1b777217e3066b
  PROTO:=git
endef

define Prepare/nginx-headers-more
	$(eval $(Download/nginx-headers-more))
	xzcat $(DL_DIR)/$(FILE) | tar -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)
endef

define Download/nginx-brotli
  VERSION:=e505dce68acc190cc5a1e780a3b0275e39f160ca
  SUBDIR:=nginx-brotli
  FILE:=ngx-brotli-module-$$(VERSION).tar.xz
  URL:=https://github.com/google/ngx_brotli.git
  MIRROR_HASH:=04847f11ef808fed50f44b2af0ef3abf59ff0ffc06dfc7394d9ab51d53fef31f
  PROTO:=git
endef

define Prepare/nginx-brotli
	$(eval $(Download/nginx-brotli))
	xzcat $(DL_DIR)/$(FILE) | tar -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)
endef

define Download/nginx-rtmp
  VERSION:=f0ea62342a4eca504b311cd5df910d026c3ea4cf
  SUBDIR:=nginx-rtmp
  FILE:=ngx-rtmp-module-$$(VERSION).tar.xz
  URL:=https://github.com/ut0mt8/nginx-rtmp-module.git
  MIRROR_HASH:=d3f58066f0f858ed79f7f2b0c9b89de2ccc512c94ab3d0625f6dcff3df0b72c1
  PROTO:=git
endef

define Prepare/nginx-rtmp
	$(eval $(Download/nginx-rtmp))
	xzcat $(DL_DIR)/$(FILE) | tar -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)
endef

define Download/nginx-ts
  VERSION:=ef2f874d95cc75747eb625a292524a702aefb0fd
  SUBDIR:=nginx-ts
  FILE:=ngx-ts-module-$$(VERSION).tar.xz
  URL:=https://github.com/arut/nginx-ts-module.git
  MIRROR_HASH:=73938950bb286d40d9e54b0994d1a63827340c1156c72eb04d7041b25b20ec18
  PROTO:=git
endef

define Prepare/nginx-ts
	$(eval $(Download/nginx-ts))
	xzcat $(DL_DIR)/$(FILE) | tar -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)
endef

define Download/nginx-naxsi
  VERSION:=951123ad456bdf5ac94e8d8819342fe3d49bc002
  SUBDIR:=nginx-naxsi
  FILE:=nginx-naxsi-module-$$(VERSION).tar.xz
  URL:=https://github.com/nbs-system/naxsi.git
  MIRROR_HASH:=c734cae19a596affadd62a2df1b58d3df8d1364093a4e80a7cd1ab4555963535
  PROTO:=git
endef

define Prepare/nginx-naxsi
	$(eval $(Download/nginx-naxsi))
	xzcat $(DL_DIR)/$(FILE) | tar -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)
endef

define Download/lua-nginx
  VERSION:=68acad14e4a8f42e31d4a4bb5ed44d6f5b55fc1c
  SUBDIR:=lua-nginx
  FILE:=lua-nginx-module-$$(VERSION).tar.xz
  URL:=https://github.com/openresty/lua-nginx-module.git
  MIRROR_HASH:=366f24e1ba6221e34f6ba20ab29146438438f88c89fd71f9500d169b3f5aedf0
  PROTO:=git
endef

define Prepare/lua-nginx
	$(eval $(Download/lua-nginx))
	xzcat $(DL_DIR)/$(FILE) | tar -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)
endef

define Download/nginx-dav-ext-module
  VERSION:=f5e30888a256136d9c550bf1ada77d6ea78a48af
  SUBDIR:=nginx-dav-ext-module
  FILE:=nginx-dav-ext-module-$$(VERSION).tar.xz
  URL:=https://github.com/arut/nginx-dav-ext-module.git
  MIRROR_HASH:=70bb4c3907f4b783605500ba494e907aede11f8505702e370012abb3c177dc5b
  PROTO:=git
endef

define Prepare/nginx-dav-ext-module
	$(eval $(Download/nginx-dav-ext-module))
	xzcat $(DL_DIR)/$(FILE) | tar -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)
endef

define Download/nginx-ubus-module
  VERSION:=b2d7260dcb428b2fb65540edb28d7538602b4a26
  SUBDIR:=nginx-ubus-module
  FILE:=nginx-ubus-module-$$(VERSION).tar.xz
  URL:=https://github.com/Ansuel/nginx-ubus-module.git
  MIRROR_HASH:=472cef416d25effcac66c85417ab6596e634a7a64d45b709bb090892d567553c
  PROTO:=git
endef

define Prepare/nginx-ubus-module
	$(eval $(Download/nginx-ubus-module))
	xzcat $(DL_DIR)/$(FILE) | tar -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)
endef

define Build/Patch
	$(if $(QUILT),rm -rf $(PKG_BUILD_DIR)/patches; mkdir -p $(PKG_BUILD_DIR)/patches)
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/nginx,nginx/)
ifneq "$(or $(CONFIG_PACKAGE_nginx-mod-dav-ext),$(QUILT))" ""
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/dav-nginx,dav-nginx/)
endif
ifneq "$(or $(CONFIG_PACKAGE_nginx-mod-lua),$(QUILT))" ""
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/lua-nginx,lua-nginx/)
endif
ifneq "$(or $(CONFIG_PACKAGE_nginx-mod-rtmp),$(QUILT))" ""
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/rtmp-nginx,rtmp-nginx/)
endif
	$(if $(QUILT),touch $(PKG_BUILD_DIR)/.quilt_used)
endef

define Quilt/Refresh/Package
	$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/nginx,nginx/)
	$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/dav-nginx,dav-nginx/)
	$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/lua-nginx,lua-nginx/)
	$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/rtmp-nginx,rtmp-nginx/)
endef

define Build/Prepare
	rm -rf $(PKG_BUILD_DIR)
	mkdir -p $(PKG_BUILD_DIR)
	$(PKG_UNPACK)

ifneq ($(CONFIG_PACKAGE_nginx-mod-naxsi),)
  $(eval $(call Download,nginx-naxsi))
  $(Prepare/nginx-naxsi)
endif

ifneq "$(or $(CONFIG_PACKAGE_nginx-mod-lua),$(QUILT))" ""
  $(eval $(call Download,lua-nginx))
  $(Prepare/lua-nginx)
endif

ifneq ($(CONFIG_PACKAGE_nginx-mod-brotli),)
  $(eval $(call Download,nginx-brotli))
  $(Prepare/nginx-brotli)
endif

ifneq ($(CONFIG_PACKAGE_nginx-mod-headers-more),)
  $(eval $(call Download,nginx-headers-more))
  $(Prepare/nginx-headers-more)
endif

ifneq "$(or $(CONFIG_PACKAGE_nginx-mod-rtmp),$(QUILT))" ""
  $(eval $(call Download,nginx-rtmp))
  $(Prepare/nginx-rtmp)
endif

ifneq ($(CONFIG_PACKAGE_nginx-mod-ts),)
  $(eval $(call Download,nginx-ts))
  $(Prepare/nginx-ts)
endif

ifneq "$(or $(CONFIG_PACKAGE_nginx-mod-dav-ext),$(QUILT))" ""
  $(eval $(call Download,nginx-dav-ext-module))
  $(Prepare/nginx-dav-ext-module)
endif

ifneq ($(CONFIG_PACKAGE_nginx-mod-ubus),)
  $(eval $(call Download,nginx-ubus-module))
  $(Prepare/nginx-ubus-module)
endif

	$(Build/Patch)
endef

$(eval $(call BuildPackage,nginx-ssl))
$(eval $(call BuildPackage,nginx-full))
$(eval $(call BuildPackage,nginx-mod-luci))

$(foreach m,$(NGINX_MODULES),$(eval $(call BuildPackage,$(m))))

# TODO: remove after a transition period (together with pkg nginx-util):
# It is for smoothly substituting nginx and nginx-mod-luci-ssl (by nginx-ssl
# respectively nginx-mod-luci). Add above commented PROVIDES when removing.

define Package/nginx
  TITLE:=Dummy package for transition when upgrading.
  DEPENDS:=+nginx-ssl
  PKGARCH:=all
endef

define Package/nginx/install
	$(INSTALL_DIR) $(1)/usr/bin
endef

$(eval $(call BuildPackage,nginx))

define Package/nginx-mod-luci-ssl
  TITLE:=Dummy package for transition when upgrading.
  DEPENDS:=+nginx-mod-luci
  PKGARCH:=all
endef

define Package/nginx-mod-luci-ssl/install
	$(INSTALL_DIR) $(1)/usr/bin
endef

$(eval $(call BuildPackage,nginx-mod-luci-ssl))
