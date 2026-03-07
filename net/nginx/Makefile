#
# Copyright (C) 2012-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nginx
PKG_VERSION:=1.26.3
PKG_RELEASE:=4

PKG_SOURCE:=nginx-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://nginx.org/download/
PKG_HASH:=69ee2b237744036e61d24b836668aad3040dda461fe6f570f1787eab570c75aa

PKG_MAINTAINER:=Thomas Heil <heil@terminal-consulting.de> \
				Christian Marangi <ansuelsmth@gmail.com>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:f5:nginx_open_source

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_BUILD_FLAGS:=gc-sections lto

# 3rd-party modules
PKG_MOD_EXTRA := \
	geoip2 \
	lua \
	lua-resty-core \
	lua-resty-lrucache \
	rtmp \
	dav-ext \
	naxsi \
	brotli \
	headers-more \
	ts \
	ubus \
	njs
# official and 3rd-party modules
PKG_MOD_ALL := \
	$(PKG_MOD_EXTRA) \
	stream
PKG_MOD_PATCHED := $(shell find patches -mindepth 1 -maxdepth 1 -type d -name 'nginx-mod-*' | sed -E 's,^patches/nginx-mod-,,')

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
	CONFIG_NGINX_HTTP_QUIC \
	CONFIG_NGINX_PCRE \
	CONFIG_NGINX_HTTP_REAL_IP \
	CONFIG_NGINX_HTTP_SECURE_LINK \
	CONFIG_NGINX_STREAM_REAL_IP \
	CONFIG_OPENSSL_ENGINE \
	CONFIG_OPENSSL_WITH_NPN \
	$(foreach m,$(PKG_MOD_EXTRA),CONFIG_PACKAGE_$(m))

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/nginx/default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Nginx web server
  URL:=https://nginx.org/
endef

define Package/nginx/description
 nginx is an HTTP and reverse proxy server, as well as a mail proxy server, \
 written by Igor Sysoev.
endef

define Package/nginx/conffiles
/etc/nginx/
endef

define Package/nginx-ssl
  $(Package/nginx/default)
  TITLE += with SSL support
  DEPENDS:= \
    +USE_GLIBC:libcrypt-compat \
    +libopenssl \
    +NGINX_PCRE:libpcre2 \
    +libpthread \
    +NGINX_DAV:libxml2 \
    +NGINX_PCRE:nginx-ssl-util \
    +!NGINX_PCRE:nginx-ssl-util-nopcre \
    +NGINX_HTTP_GZIP:zlib
  EXTRA_DEPENDS:=nginx-ssl-util$(if $(CONFIG_NGINX_PCRE),,-nopcre) (>=1.5-r1)
  PROVIDES:=nginx
  VARIANT:=ssl
  DEFAULT_VARIANT:=1
  CONFLICTS:=nginx-full
endef

Package/nginx-ssl/description = $(Package/nginx/description) \
  This variant is compiled with SSL support enabled. To enable additional module \
  select them in the nginx default configuration menu.

define Package/nginx-ssl/config
  source "$(SOURCE)/Config_ssl.in"
endef

Package/nginx-ssl/conffiles = $(Package/nginx/conffiles)

IsEnabled = $(or $(filter full,$(BUILD_VARIANT)),$(CONFIG_$(1)))
IsDisabled = $(if $(call IsEnabled,$(1)),,1)

config_files := mime.types \
	$(if $(call IsEnabled,NGINX_HTTP_CHARSET),koi-utf koi-win win-utf) \
	$(if $(call IsEnabled,NGINX_HTTP_FASTCGI),fastcgi_params) \
	$(if $(call IsEnabled,NGINX_HTTP_UWSGI),uwsgi_params) \
	$(if $(call IsEnabled,NGINX_HTTP_SCGI),scgi_params)

define Package/nginx-ssl/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/nginx $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/nginx/module.d
	$(INSTALL_DIR) $(1)/etc/nginx/conf.d
	$(INSTALL_DATA) $(addprefix $(PKG_INSTALL_DIR)/etc/nginx/,$(config_files)) $(1)/etc/nginx/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/nginx.init $(1)/etc/init.d/nginx
endef

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

define Package/nginx-full
  $(Package/nginx/default)
  TITLE += with ALL config selected
  DEPENDS:= \
    +USE_GLIBC:libcrypt-compat \
    +libopenssl \
    +libpcre2 \
    +libpthread \
    +libxml2 \
    +nginx-ssl-util \
    +zlib
  EXTRA_DEPENDS:=nginx-ssl-util (>=1.5-r1)
  PROVIDES=nginx
  VARIANT:=full
endef

Package/nginx-full/description = $(Package/nginx/description) \
  This variant is compiled with ALL config selected.

Package/nginx-full/install = $(Package/nginx-ssl/install)

Package/nginx-full/prerm = $(Package/nginx-ssl/prerm)

Package/nginx-full/conffiles = $(Package/nginx/conffiles)

define Package/nginx-mod-luci
  TITLE:=Nginx on LuCI
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Support file for Nginx
  URL:=http://nginx.org/
  DEPENDS:=+uwsgi +uwsgi-luci-support +nginx +nginx-mod-ubus
endef

define Package/nginx-mod-luci/description
 Support file for LuCI in nginx. Include custom nginx configuration, autostart script for uwsgi.
endef

define Package/nginx-mod-luci/preinst
#!/bin/sh
grep -r -l ngx_http_ubus_module.so /etc/nginx/module.d | grep -v ngx_http_ubus.module | while read file; do
  echo "Removing old LuCI module load file for 'ngx_http_ubus.so' in $$file."
  rm -f $$file
done
exit 0
endef

define Package/nginx-mod-luci/install
	$(INSTALL_DIR) $(1)/etc/nginx/conf.d
	$(INSTALL_CONF) ./files-luci-support/luci.locations $(1)/etc/nginx/conf.d/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files-luci-support/60_nginx-luci-support $(1)/etc/uci-defaults/60_nginx-luci-support
endef

define Download/nginx-mod-geoip2
  SOURCE_VERSION:=3.4
  URL:=https://github.com/leev/ngx_http_geoip2_module
  MIRROR_HASH:=22d67e35067faed200ea398581dd0dc9d599bc6ab4c0ea2034a1ea55666fdc1d
  PROTO:=git
endef

define Package/nginx-mod-lua-resty-lrucache
  $(call Package/nginx/default)
  TITLE:=Nginx Lua OpenResty lrucache module
  DEPENDS:=@HAS_LUAJIT_ARCH +luajit2
endef

define Package/nginx-mod-lua-resty-core
  $(call Package/nginx/default)
  TITLE:=Nginx Lua OpenResty core module
  DEPENDS:=+nginx-mod-lua-resty-lrucache
endef

define Package/nginx-mod-lua-resty-lrucache/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/resty/lrucache
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nginx-mod-lua-resty-lrucache/lib/resty/*.lua $(1)/usr/lib/lua/resty
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nginx-mod-lua-resty-lrucache/lib/resty/lrucache/*.lua $(1)/usr/lib/lua/resty/lrucache
endef

define Package/nginx-mod-lua-resty-core/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/ngx/ssl
	$(INSTALL_DIR) $(1)/usr/lib/lua/resty/core
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nginx-mod-lua-resty-core/lib/ngx/*.lua $(1)/usr/lib/lua/ngx
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nginx-mod-lua-resty-core/lib/ngx/ssl/*.lua $(1)/usr/lib/lua/ngx/ssl
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nginx-mod-lua-resty-core/lib/resty/*.lua $(1)/usr/lib/lua/resty
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nginx-mod-lua-resty-core/lib/resty/core/*.lua $(1)/usr/lib/lua/resty/core
endef

define Download/nginx-mod-headers-more
  SOURCE_DATE:=2022-07-17
  SOURCE_VERSION:=bea1be3bbf6af28f6aa8cf0c01c07ee1637e2bd0
  URL:=https://github.com/openresty/headers-more-nginx-module.git
  MIRROR_HASH:=569abadc137b5b52bdcc33b00aa21f6d266cb84fb891795da2c4e101c4898abe
  PROTO:=git
endef

define Download/nginx-mod-brotli
  SOURCE_DATE:=2020-04-23
  SOURCE_VERSION:=25f86f0bac1101b6512135eac5f93c49c63609e3
  URL:=https://github.com/google/ngx_brotli.git
  MIRROR_HASH:=680c56be79e7327cb8df271646119333d2f6965a3472bc7043721625fa4488f5
  PROTO:=git
endef

define Download/nginx-mod-rtmp
  SOURCE_DATE:=2018-12-07
  SOURCE_VERSION:=f0ea62342a4eca504b311cd5df910d026c3ea4cf
  URL:=https://github.com/ut0mt8/nginx-rtmp-module.git
  MIRROR_HASH:=9c98d886ae4ea3708bb0bca55f8df803418a407e0ffc6df56341bd76ad39cba8
  PROTO:=git
endef

define Download/nginx-mod-ts
  SOURCE_DATE:=2017-12-04
  SOURCE_VERSION:=ef2f874d95cc75747eb625a292524a702aefb0fd
  URL:=https://github.com/arut/nginx-ts-module.git
  MIRROR_HASH:=3f144d4615a4aaa1215435cd06ae4054ea12206d5b38306321420f7acc62aca8
  PROTO:=git
endef

define Download/nginx-mod-naxsi
  SOURCE_DATE:=2022-09-14
  SOURCE_VERSION:=d714f1636ea49a9a9f4f06dba14aee003e970834
  URL:=https://github.com/nbs-system/naxsi.git
  MIRROR_HASH:=b0cef5fbf842f283eb5f0686ddd1afcd07d83abd7027c8cfb3e84a2223a34797
  PROTO:=git
endef

define Download/nginx-mod-lua
  SOURCE_DATE:=2023-08-19
  SOURCE_VERSION:=c89469e920713d17d703a5f3736c9335edac22bf
  URL:=https://github.com/openresty/lua-nginx-module.git
  MIRROR_HASH:=c3bdf1b23f0a63991b5dcbd1f8ee150e6f893b43278e8600e4e0bb42a6572db4
  PROTO:=git
endef

define Download/nginx-mod-lua-resty-core
  SOURCE_DATE:=2023-09-09
  SOURCE_VERSION:=2e2b2adaa61719972fe4275fa4c3585daa0dcd84
  URL:=https://github.com/openresty/lua-resty-core.git
  MIRROR_HASH:=c5f3df92fd72eac5b54497c039aca0f0d9ea1d87223f1e3a54365ba565991874
  PROTO:=git
endef

define Download/nginx-mod-lua-resty-lrucache
  SOURCE_DATE:=2023-08-06
  SOURCE_VERSION:=52f5d00403c8b7aa8a4d4f3779681976b10a18c1
  URL:=https://github.com/openresty/lua-resty-lrucache.git
  MIRROR_HASH:=0833e0114948af4edb216c5c34b3f1919f534b298f4fa29739544f7c9bb8a08d
  PROTO:=git
endef

define Download/nginx-mod-dav-ext
  SOURCE_DATE:=2018-12-17
  SOURCE_VERSION:=f5e30888a256136d9c550bf1ada77d6ea78a48af
  URL:=https://github.com/arut/nginx-dav-ext-module.git
  MIRROR_HASH:=c574e60ffab5f6e5d8bea18aab0799c19cd9a84f3d819b787e9af4f0e7867b52
  PROTO:=git
endef

define Download/nginx-mod-ubus
  SOURCE_DATE:=2020-09-06
  SOURCE_VERSION:=b2d7260dcb428b2fb65540edb28d7538602b4a26
  URL:=https://github.com/Ansuel/nginx-ubus-module.git
  MIRROR_HASH:=515bb9d355ad80916f594046a45c190a68fb6554d6795a54ca15cab8bdd12fda
  PROTO:=git
endef

define Download/nginx-mod-njs
  SOURCE_DATE:=2024-10-03
  SOURCE_VERSION:=c5a29a7af8894ee1ec44ebda71ef0ea1f2a31af6
  URL:=https://github.com/nginx/njs.git
  MIRROR_HASH:=6c94ec6b1c119e0c7a85ec395a4987a8a61739e1f9256ce6d92a16804c5d4637
  PROTO:=git
endef

define Module/Download
  define Download/nginx-mod-$(1) +=

    SUBDIR:=nginx-mod-$(1)
    FILE:=nginx-mod-$(1)-$$$$(subst -,.,$$$$(SOURCE_DATE))~$$$$(call version_abbrev,$$$$(SOURCE_VERSION)).tar.zst
  endef
endef
$(foreach m,$(PKG_MOD_EXTRA),$(eval $(call Module/Download,$(m))))

define Module/nginx-mod-naxsi/install
	$(INSTALL_DIR) $(1)/etc/nginx
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/nginx-mod-naxsi/naxsi_config/naxsi_core.rules $(1)/etc/nginx
endef

define Quilt/Refresh/Package
	$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/nginx,nginx/)
	$(foreach m,$(PKG_MOD_PATCHED),
		$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/nginx-mod-$(m),nginx-mod-$(m)/)
	)
endef

define Build/Patch
	$(if $(QUILT),rm -rf $(PKG_BUILD_DIR)/patches; mkdir -p $(PKG_BUILD_DIR)/patches)
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/nginx,nginx/)
	$(foreach m,$(PKG_MOD_PATCHED),$(if $(or $(CONFIG_PACKAGE_nginx-mod-$(m)),$(QUILT)),
		$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/nginx-mod-$(m),nginx-mod-$(m)/)
	))
	$(if $(QUILT),touch $(PKG_BUILD_DIR)/.quilt_used)
endef

define Module/Build/Prepare
	$(eval $(call Download,nginx-mod-$(1)))
	$(eval $(Download/nginx-mod-$(1)))
	mkdir -p $(PKG_BUILD_DIR)/nginx-mod-$(1)
	zstdcat $(DL_DIR)/$(FILE) | tar -C $(PKG_BUILD_DIR)/nginx-mod-$(1) $(TAR_OPTIONS) --strip-components 1
endef

define Build/Prepare
	rm -rf $(PKG_BUILD_DIR)
	mkdir -p $(PKG_BUILD_DIR)
	$(PKG_UNPACK)

	$(foreach m,$(filter-out $(PKG_MOD_PATCHED),$(PKG_MOD_EXTRA)),$(if $(CONFIG_PACKAGE_nginx-mod-$(m)),
		$(call Module/Build/Prepare,$(m))
	))
	$(foreach m,$(PKG_MOD_PATCHED),$(if $(or $(CONFIG_PACKAGE_nginx-mod-$(m)),$(QUILT)),
		$(call Module/Build/Prepare,$(m))
	))
	$(Build/Patch)
endef

# $(1) module name
# $(2) module additional dependency
# $(3) module so name (stripped of the finally _module.so)
# $(4) module description
define BuildModule
  define Package/nginx-mod-$(1)
    $(call Package/nginx/default)
    DEPENDS:=+nginx $(2)
    TITLE:=Nginx $(1) module
  endef

  define Package/nginx-mod-$(1)/description
    $(strip $(4))
  endef

  define Package/nginx-mod-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/lib/nginx/modules
	$(INSTALL_DIR) $$(1)/etc/nginx/module.d
	$(foreach m,$(3),
	  $(CP) $$(PKG_INSTALL_DIR)/usr/lib/nginx/modules/$(m)_module.so $$(1)/usr/lib/nginx/modules && \
	  echo "load_module /usr/lib/nginx/modules/$(m)_module.so;" > $$(1)/etc/nginx/module.d/$(m).module
	)
	$(call Module/nginx-mod-$(1)/install,$$(1))
  endef

  $$(eval $$(call BuildPackage,nginx-mod-$(1)))
endef

TARGET_CFLAGS += -DNGX_LUA_NO_BY_LUA_BLOCK

ifneq ($(CONFIG_PACKAGE_nginx-mod-lua),)
  CONFIGURE_VARS += LUAJIT_INC=$(STAGING_DIR)/usr/include/luajit-* \
					LUAJIT_LIB=$(STAGING_DIR)/usr/lib
endif

CONFIGURE_VARS += LIBXML2_INC=$(STAGING_DIR)/usr/include/libxml2 \
			CONFIG_BIG_ENDIAN=$(CONFIG_BIG_ENDIAN)

CONFIGURE_ARGS += \
	--crossbuild=Linux::$(ARCH) \
	--prefix=/usr \
	--conf-path=/etc/nginx/nginx.conf \
	--modules-path=/usr/lib/nginx/modules \
	--error-log-path=stderr \
	--pid-path=/var/run/nginx.pid \
	--lock-path=/var/lock/nginx.lock \
	--http-log-path=/var/log/nginx/access.log \
	--http-client-body-temp-path=/var/lib/nginx/body \
	--http-proxy-temp-path=/var/lib/nginx/proxy \
	--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
	--with-cc="$(TARGET_CC)" \
	--with-ld-opt="$(TARGET_LDFLAGS)" \
	--without-http_upstream_zone_module \
	--with-compat \
	--with-http_ssl_module \
	$(if $(call IsDisabled,NGINX_HTTP_CACHE),--without-http-cache) \
	$(if $(call IsDisabled,NGINX_PCRE),--without-pcre) \
	$(if $(call IsDisabled,NGINX_HTTP_CHARSET),--without-http_charset_module) \
	$(if $(call IsDisabled,NGINX_HTTP_GZIP),--without-http_gzip_module) \
	$(if $(call IsDisabled,NGINX_HTTP_SSI),--without-http_ssi_module) \
	$(if $(call IsDisabled,NGINX_HTTP_USERID),--without-http_userid_module) \
	$(if $(call IsDisabled,NGINX_HTTP_ACCESS),--without-http_access_module) \
	$(if $(call IsDisabled,NGINX_HTTP_AUTH_BASIC),--without-http_auth_basic_module) \
	$(if $(call IsDisabled,NGINX_HTTP_AUTOINDEX),--without-http_autoindex_module) \
	$(if $(call IsDisabled,NGINX_HTTP_GEO),--without-http_geo_module) \
	$(if $(call IsDisabled,NGINX_HTTP_MAP),--without-http_map_module) \
	$(if $(call IsDisabled,NGINX_HTTP_SPLIT_CLIENTS),--without-http_split_clients_module) \
	$(if $(call IsDisabled,NGINX_HTTP_REFERER),--without-http_referer_module) \
	$(if $(call IsDisabled,NGINX_HTTP_REWRITE),--without-http_rewrite_module) \
	$(if $(call IsDisabled,NGINX_HTTP_PROXY),--without-http_proxy_module) \
	$(if $(call IsDisabled,NGINX_HTTP_FASTCGI),--without-http_fastcgi_module) \
	$(if $(call IsDisabled,NGINX_HTTP_UWSGI),--without-http_uwsgi_module) \
	$(if $(call IsDisabled,NGINX_HTTP_SCGI),--without-http_scgi_module) \
	$(if $(call IsDisabled,NGINX_HTTP_MEMCACHED),--without-http_memcached_module) \
	$(if $(call IsDisabled,NGINX_HTTP_LIMIT_CONN),--without-http_limit_conn_module) \
	$(if $(call IsDisabled,NGINX_HTTP_LIMIT_REQ),--without-http_limit_req_module) \
	$(if $(call IsDisabled,NGINX_HTTP_EMPTY_GIF),--without-http_empty_gif_module) \
	$(if $(call IsDisabled,NGINX_HTTP_BROWSER),--without-http_browser_module) \
	$(if $(call IsDisabled,NGINX_HTTP_UPSTREAM_HASH),--without-http_upstream_hash_module) \
	$(if $(call IsDisabled,NGINX_HTTP_UPSTREAM_IP_HASH),--without-http_upstream_ip_hash_module) \
	$(if $(call IsDisabled,NGINX_HTTP_UPSTREAM_LEAST_CONN),--without-http_upstream_least_conn_module) \
	$(if $(call IsDisabled,NGINX_HTTP_UPSTREAM_KEEPALIVE),--without-http_upstream_keepalive_module) \
	$(if $(call IsEnabled,IPV6),--with-ipv6) \
	$(if $(call IsEnabled,NGINX_HTTP_GZIP_STATIC),--with-http_gzip_static_module) \
	$(if $(call IsEnabled,NGINX_STUB_STATUS),--with-http_stub_status_module) \
	$(if $(call IsEnabled,NGINX_FLV),--with-http_flv_module) \
	$(if $(call IsEnabled,NGINX_DAV),--with-http_dav_module) \
	$(if $(call IsEnabled,NGINX_HTTP_AUTH_REQUEST),--with-http_auth_request_module) \
	$(if $(call IsEnabled,NGINX_HTTP_QUIC),--with-http_v3_module) \
	$(if $(call IsEnabled,NGINX_HTTP_V2),--with-http_v2_module) \
	$(if $(call IsEnabled,NGINX_HTTP_REAL_IP),--with-http_realip_module) \
	$(if $(call IsEnabled,NGINX_HTTP_SECURE_LINK),--with-http_secure_link_module) \
	$(if $(call IsEnabled,NGINX_HTTP_SUB),--with-http_sub_module) \
	$(if $(CONFIG_PACKAGE_nginx-mod-stream),--with-stream=dynamic --with-stream_ssl_module --with-stream_ssl_preread_module) \
	$(if $(call IsEnabled,NGINX_STREAM_REAL_IP),--with-stream_realip_module) \
	$(if $(CONFIG_PACKAGE_nginx-mod-naxsi),--add-dynamic-module=$(PKG_BUILD_DIR)/nginx-mod-naxsi/naxsi_src) \
	$(if $(CONFIG_PACKAGE_nginx-mod-njs),--add-dynamic-module=$(PKG_BUILD_DIR)/nginx-mod-njs/nginx) \
	$(foreach m,$(filter-out lua-resty-core lua-resty-lrucache naxsi njs,$(PKG_MOD_EXTRA)), \
		$(if $(CONFIG_PACKAGE_nginx-mod-$(m)),--add-dynamic-module=$(PKG_BUILD_DIR)/nginx-mod-$(m)))

$(eval $(call BuildPackage,nginx-ssl))
$(eval $(call BuildPackage,nginx-full))
$(eval $(call BuildPackage,nginx-mod-luci))
$(eval $(call BuildPackage,nginx-mod-lua-resty-lrucache))
$(eval $(call BuildPackage,nginx-mod-lua-resty-core))
$(eval $(call BuildModule,stream,+@NGINX_STREAM_CORE_MODULE, \
	ngx_stream, Add support for NGINX request streaming.))
$(eval $(call BuildModule,lua,+nginx-mod-lua-resty-core,ngx_http_lua, \
	Enable Lua module (luajit2 based, OpenResty patches)))
$(eval $(call BuildModule,ubus,+libubus +libjson-c +libblobmsg-json, \
	ngx_http_ubus,Enable UBUS api support directly from the server.))
$(eval $(call BuildModule,dav-ext,+@NGINX_DAV +libxml2,ngx_http_dav_ext, \
	Enable the WebDAV methods PROPFIND OPTIONS LOCK UNLOCK.))
$(eval $(call BuildModule,headers-more,,ngx_http_headers_more_filter, \
	Set and clear input and output headers...more than "add"!))
$(eval $(call BuildModule,rtmp,,ngx_rtmp, \
	Add support for NGINX-based Media Streaming Server module. DASH enhanced))
$(eval $(call BuildModule,ts,,ngx_http_ts, \
	Add support for MPEG-TS Live Module module.))
$(eval $(call BuildModule,brotli,,ngx_http_brotli_filter ngx_http_brotli_static, \
	Add support for brotli compression module.))
$(eval $(call BuildModule,naxsi,,ngx_http_naxsi, \
	Enable NAXSI module.))
$(eval $(call BuildModule,geoip2,+@NGINX_STREAM_CORE_MODULE +nginx-mod-stream +libmaxminddb,ngx_http_geoip2 ngx_stream_geoip2, \
	Enable MaxMind GeoIP2 module.))
$(eval $(call BuildModule,njs,+zlib +libxml2 +libxslt +libpcre2,ngx_http_js, \
	Enable NJS module.))
