include $(TOPDIR)/rules.mk

PKG_NAME:=lua-eco
PKG_VERSION:=2.5.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL=https://github.com/zhaojh329/lua-eco/releases/download/v$(PKG_VERSION)
PKG_HASH:=d41668d137780f2655ebfec88276249bb9cd5c53f758c3e2103eb001ed9b5d02

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
  TITLE:=A Lua interpreter with a built-in libev event loop
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Lua
  URL:=https://github.com/zhaojh329/lua-eco
  DEPENDS:=+libev +liblua +luabitop
endef

define Package/lua-eco/description
  Lua-eco is a Lua interpreter with a built-in event loop for scheduling
  lightweight coroutines automatically, enabling efficient concurrency in
  Lua. Build high-performance, scalable applications.
endef

define Package/lua-eco/Module
  TITLE:=$1 support for lua-eco
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Lua
  URL:=https://github.com/zhaojh329/lua-eco
  DEPENDS:=+lua-eco $2
endef

Package/lua-eco-log=$(call Package/lua-eco/Module,log utils)
Package/lua-eco-sys=$(call Package/lua-eco/Module,system utils)
Package/lua-eco-file=$(call Package/lua-eco/Module,file utils)
Package/lua-eco-base64=$(call Package/lua-eco/Module,base64)
Package/lua-eco-sha1=$(call Package/lua-eco/Module,sha1)
Package/lua-eco-md5=$(call Package/lua-eco/Module,md5)
Package/lua-eco-socket=$(call Package/lua-eco/Module,socket,+lua-eco-file +lua-eco-sys)
Package/lua-eco-dns=$(call Package/lua-eco/Module,dns,+lua-eco-socket)
Package/lua-eco-ssl=$(call Package/lua-eco/Module,ssl,\
  +LUA_ECO_OPENSSL:libopenssl +LUA_ECO_WOLFSSL:libwolfssl \
  +LUA_ECO_MBEDTLS:libmbedtls +LUA_ECO_MBEDTLS:zlib +lua-eco-socket)
Package/lua-eco-ubus=$(call Package/lua-eco/Module,ubus,+libubus)
Package/lua-eco-http=$(call Package/lua-eco/Module,http/https,+lua-eco-dns +lua-eco-ssl +lua-eco-log)
Package/lua-eco-mqtt=$(call Package/lua-eco/Module,mqtt,+lua-eco-socket +lua-eco-dns +lua-mosquitto)
Package/lua-eco-websocket=$(call Package/lua-eco/Module,websocket,+lua-eco-http +lua-eco-base64 +lua-eco-sha1)
Package/lua-eco-termios=$(call Package/lua-eco/Module,termios)
Package/lua-eco-struct=$(call Package/lua-eco/Module,struct pack)
Package/lua-eco-netlink=$(call Package/lua-eco/Module,netlink,+lua-eco-socket)
Package/lua-eco-ip=$(call Package/lua-eco/Module,ip utils,+lua-eco-netlink)
Package/lua-eco-nl80211=$(call Package/lua-eco/Module,nl80211,+lua-eco-netlink)

define Package/lua-eco-ssl/config
	choice
		prompt "SSL Library"
		default LUA_ECO_MBEDTLS

		config LUA_ECO_OPENSSL
			bool "OpenSSL"

		config LUA_ECO_WOLFSSL
			bool "wolfSSL"

		config LUA_ECO_MBEDTLS
			bool "mbedTLS"
	endchoice
endef

CMAKE_OPTIONS += \
  -DPLATFORM="openwrt" \
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
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/lua/eco/core $(1)/usr/lib/lua/eco/encoding
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/eco $(1)/usr/bin
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/encoding/hex.lua $(1)/usr/lib/lua/eco/encoding
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/core/{time,bufio}.so $(1)/usr/lib/lua/eco/core
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/{time,bufio,bit,sync}.lua $(1)/usr/lib/lua/eco
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/binary.so $(1)/usr/lib/lua/eco
endef

define Package/lua-eco-log/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/eco
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/log.so $(1)/usr/lib/lua/eco
endef

define Package/lua-eco-sys/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/eco/core
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/sys.lua $(1)/usr/lib/lua/eco
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/core/sys.so $(1)/usr/lib/lua/eco/core
endef

define Package/lua-eco-file/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/eco/core
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/file.lua $(1)/usr/lib/lua/eco
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/core/file.so $(1)/usr/lib/lua/eco/core
endef

define Package/lua-eco-base64/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/eco/encoding
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/encoding/base64.so $(1)/usr/lib/lua/eco/encoding
endef

define Package/lua-eco-sha1/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/eco/crypto
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/crypto/sha1.so $(1)/usr/lib/lua/eco/crypto
endef

define Package/lua-eco-md5/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/eco/crypto
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/crypto/md5.so $(1)/usr/lib/lua/eco/crypto
endef

define Package/lua-eco-socket/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/eco/core
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/socket.lua $(1)/usr/lib/lua/eco
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/core/socket.so $(1)/usr/lib/lua/eco/core
endef

define Package/lua-eco-dns/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/eco
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/dns.lua $(1)/usr/lib/lua/eco
endef

define Package/lua-eco-ssl/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/eco/core
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/ssl.lua $(1)/usr/lib/lua/eco
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/core/ssl.so $(1)/usr/lib/lua/eco/core
endef

define Package/lua-eco-ubus/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/eco/core
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/ubus.lua $(1)/usr/lib/lua/eco
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/core/ubus.so $(1)/usr/lib/lua/eco/core
endef

define Package/lua-eco-http/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/eco
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/{url,http}.lua $(1)/usr/lib/lua/eco
endef

define Package/lua-eco-mqtt/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/eco
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/mqtt.lua $(1)/usr/lib/lua/eco
endef

define Package/lua-eco-websocket/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/eco
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/websocket.lua $(1)/usr/lib/lua/eco
endef

define Package/lua-eco-termios/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/eco
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/termios.so $(1)/usr/lib/lua/eco
endef

define Package/lua-eco-struct/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/eco
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/struct.so $(1)/usr/lib/lua/eco
endef

define Package/lua-eco-netlink/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/eco/core
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/{nl,genl}.lua $(1)/usr/lib/lua/eco
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/core/{nl,genl}.so $(1)/usr/lib/lua/eco/core
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/rtnl.so $(1)/usr/lib/lua/eco
endef

define Package/lua-eco-ip/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/eco
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/ip.lua $(1)/usr/lib/lua/eco
endef

define Package/lua-eco-nl80211/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/eco/core
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/nl80211.lua $(1)/usr/lib/lua/eco
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/eco/core/nl80211.so $(1)/usr/lib/lua/eco/core
endef

$(eval $(call BuildPackage,lua-eco))
$(eval $(call BuildPackage,lua-eco-log))
$(eval $(call BuildPackage,lua-eco-sys))
$(eval $(call BuildPackage,lua-eco-file))
$(eval $(call BuildPackage,lua-eco-base64))
$(eval $(call BuildPackage,lua-eco-sha1))
$(eval $(call BuildPackage,lua-eco-md5))
$(eval $(call BuildPackage,lua-eco-socket))
$(eval $(call BuildPackage,lua-eco-dns))
$(eval $(call BuildPackage,lua-eco-ssl))
$(eval $(call BuildPackage,lua-eco-ubus))
$(eval $(call BuildPackage,lua-eco-http))
$(eval $(call BuildPackage,lua-eco-mqtt))
$(eval $(call BuildPackage,lua-eco-websocket))
$(eval $(call BuildPackage,lua-eco-termios))
$(eval $(call BuildPackage,lua-eco-netlink))
$(eval $(call BuildPackage,lua-eco-ip))
$(eval $(call BuildPackage,lua-eco-nl80211))
