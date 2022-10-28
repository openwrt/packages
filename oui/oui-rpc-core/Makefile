#
# Copyright (C) 2022 Jianhui Zhao <zhaojh329@gmail.com>
#
# This is free software, licensed under the MIT.
#

include $(TOPDIR)/rules.mk
include ../version.mk

PKG_NAME:=oui-rpc-core
PKG_VERSION:=$(strip $(call findrev))
PKG_RELEASE:=1

PKG_MAINTAINER:=Jianhui Zhao <zhaojh329@gmail.com>
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/oui-rpc-core
  SECTION:=oui
  CATEGORY:=Oui
  TITLE:=Oui rpc core
  URL:=https://github.com/zhaojh329/oui
  DEPENDS:=+liblua +libuci-lua +libiwinfo-lua +libubus-lua +lua-cjson +nginx-ssl \
  	+@NGINX_HTTP_GZIP_STATIC +@NGINX_HTTP_ACCESS +@NGINX_HTTP_REWRITE +@NGINX_LUA
endef

define Package/oui-rpc-core/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/nginx/conf.d $(1)/etc/nginx/lua \
		$(1)/usr/share/oui $(1)/usr/lib/lua/oui $(1)/usr/share/oui/acl
	$(INSTALL_CONF) ./files/oui.config $(1)/etc/config/oui
	$(INSTALL_CONF) ./files/ngx/oui.locations $(1)/etc/nginx/conf.d
	$(INSTALL_CONF) ./files/ngx/oui.conf $(1)/etc/nginx/conf.d
	$(INSTALL_CONF) ./files/ngx/oui-rpc.lua $(1)/etc/nginx/lua
	$(INSTALL_CONF) ./files/ngx/oui-upload.lua $(1)/etc/nginx/lua
	$(INSTALL_CONF) ./files/ngx/oui-download.lua $(1)/etc/nginx/lua
	$(INSTALL_CONF) ./files/admin.acl $(1)/usr/share/oui/acl/admin.json
	$(CP) ./files/lib/oui $(1)/usr/lib/lua
	$(CP) ./files/lib/resty $(1)/usr/lib/lua
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/oui $(1)/usr/lib/lua
	$(CP) ./files/rpc $(1)/usr/share/oui
endef

$(eval $(call BuildPackage,oui-rpc-core))
