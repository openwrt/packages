include $(TOPDIR)/rules.mk

PKG_NAME:=lua-eco
PKG_VERSION:=1.0.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL=https://github.com/zhaojh329/lua-eco/releases/download/v$(PKG_VERSION)
PKG_HASH:=d9fd04acb4bd64f47a3a3e6a8d30ee1d0860221c5798ca528cf52260470b4155

PKG_MAINTAINER:=Jianhui Zhao <zhaojh329@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_CONFIG_DEPENDS:= \
	LUA_ECO_OPENSSL \
	LUA_ECO_WOLFSSL \
	LUA_ECO_MBEDTLS

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/lua-eco
  TITLE:=A Lua coroutine library
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Lua
  URL:=https://github.com/zhaojh329/lua-eco
  DEPENDS:=+libev
endef

define Package/lua-eco/description
  Lua-eco is a Lua coroutine library which was implemented based on IO event.
endef

define Package/lua-eco/Module
  TITLE:=$1 support for lua-eco
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Lua
  URL:=https://github.com/zhaojh329/lua-eco
  DEPENDS:=+lua-eco $2
endef

Package/lua-eco-log=$(call Package/lua-eco/Module,Log utils)
Package/lua-eco-sys=$(call Package/lua-eco/Module,System utils)
Package/lua-eco-dns=$(call Package/lua-eco/Module,DNS)
Package/lua-eco-socket=$(call Package/lua-eco/Module,Socket)
Package/lua-eco-ssl=$(call Package/lua-eco/Module,SSL,\
  @(PACKAGE_libopenssl||PACKAGE_libwolfssl||PACKAGE_libmbedtls) \
  LUA_ECO_OPENSSL:libopenssl LUA_ECO_WOLFSSL:libwolfssl \
  LUA_ECO_MBEDTLS:libmbedtls +LUA_ECO_MBEDTLS:zlib)
Package/lua-eco-iw=$(call Package/lua-eco/Module,IW utils,+libmnl)
Package/lua-eco-ip=$(call Package/lua-eco/Module,IP utils,+libmnl)
Package/lua-eco-file=$(call Package/lua-eco/Module,File utils)
Package/lua-eco-ubus=$(call Package/lua-eco/Module,Ubus,+libubus)

define Package/lua-eco-ssl/config
    config LUA_ECO_DEFAULT_WOLFSSL
	bool
	default y if PACKAGE_libopenssl != y && \
		     PACKAGE_libwolfssl >= PACKAGE_libopenssl && \
		     PACKAGE_libwolfssl >= PACKAGE_libmbedtls

    config LUA_ECO_DEFAULT_OPENSSL
	bool
	default y if !LUA_ECO_DEFAULT_WOLFSSL && \
		     PACKAGE_libopenssl >= PACKAGE_libmbedtls

    config LUA_ECO_DEFAULT_MBEDTLS
	bool
	default y if !LUA_ECO_DEFAULT_WOLFSSL && \
		     !LUA_ECO_DEFAULT_OPENSSL

    choice
	prompt "SSL Library"
	default LUA_ECO_OPENSSL if LUA_ECO_DEFAULT_OPENSSL
	default LUA_ECO_WOLFSSL if LUA_ECO_DEFAULT_WOLFSSL
	default LUA_ECO_MBEDTLS if LUA_ECO_DEFAULT_MBEDTLS
	config LUA_ECO_OPENSSL
		bool "OpenSSL"
		depends on PACKAGE_libopenssl
	config LUA_ECO_WOLFSSL
		bool "wolfSSL"
		depends on PACKAGE_libwolfssl
	config LUA_ECO_MBEDTLS
		bool "mbedTLS"
		depends on PACKAGE_libmbedtls
    endchoice
endef

CMAKE_OPTIONS += \
  -DECO_LOG_SUPPORT=O$(if $(CONFIG_PACKAGE_lua-eco-log),N,FF) \
  -DECO_SYS_SUPPORT=O$(if $(CONFIG_PACKAGE_lua-eco-sys),N,FF) \
  -DECO_DNS_SUPPORT=O$(if $(CONFIG_PACKAGE_lua-eco-dns),N,FF) \
  -DECO_SOCKET_SUPPORT=O$(if $(CONFIG_PACKAGE_lua-eco-socket),N,FF) \
  -DECO_IW_SUPPORT=O$(if $(CONFIG_PACKAGE_lua-eco-iw),N,FF) \
  -DECO_IP_SUPPORT=O$(if $(CONFIG_PACKAGE_lua-eco-ip),N,FF) \
  -DECO_FILE_SUPPORT=O$(if $(CONFIG_PACKAGE_lua-eco-file),N,FF) \
  -DECO_UBUS_SUPPORT=O$(if $(CONFIG_PACKAGE_lua-eco-ubus),N,FF) \
  -DECO_SSL_SUPPORT=O$(if $(CONFIG_PACKAGE_lua-eco-ssl),N,FF)

ifneq ($(CONFIG_PACKAGE_lua-eco-ssl),)
  ifneq ($(CONFIG_LUA_ECO_OPENSSL),)
    CMAKE_OPTIONS += -DUSE_OPENSSL=ON
  else ifneq ($(CONFIG_LUA_ECO_WOLFSSL),)
    CMAKE_OPTIONS += -DUSE_WOLFSSL=ON
  else ifneq ($(CONFIG_LUA_ECO_MBEDTLS),)
    CMAKE_OPTIONS += -DUSE_MBEDTLS=ON
  endif
endif

define Package/lua-eco/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eco.so $(1)/usr/lib/lua
endef

define Package/lua-eco/Module/install  
	$(INSTALL_DIR) $(1)/usr/lib/lua/eco
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$2.so $(1)/usr/lib/lua/eco
endef

Package/lua-eco-log/install=$(call Package/lua-eco/Module/install,$1,log)
Package/lua-eco-sys/install=$(call Package/lua-eco/Module/install,$1,sys)
Package/lua-eco-dns/install=$(call Package/lua-eco/Module/install,$1,dns)
Package/lua-eco-socket/install=$(call Package/lua-eco/Module/install,$1,socket)
Package/lua-eco-ssl/install=$(call Package/lua-eco/Module/install,$1,ssl)
Package/lua-eco-iw/install=$(call Package/lua-eco/Module/install,$1,iw)
Package/lua-eco-ip/install=$(call Package/lua-eco/Module/install,$1,ip)
Package/lua-eco-file/install=$(call Package/lua-eco/Module/install,$1,file)
Package/lua-eco-ubus/install=$(call Package/lua-eco/Module/install,$1,ubus)

$(eval $(call BuildPackage,lua-eco))
$(eval $(call BuildPackage,lua-eco-log))
$(eval $(call BuildPackage,lua-eco-sys))
$(eval $(call BuildPackage,lua-eco-dns))
$(eval $(call BuildPackage,lua-eco-socket))
$(eval $(call BuildPackage,lua-eco-ssl))
$(eval $(call BuildPackage,lua-eco-iw))
$(eval $(call BuildPackage,lua-eco-ip))
$(eval $(call BuildPackage,lua-eco-file))
$(eval $(call BuildPackage,lua-eco-ubus))
