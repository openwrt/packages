include $(TOPDIR)/rules.mk

PKG_NAME:=lua-eco
PKG_VERSION:=3.5.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL=https://github.com/zhaojh329/lua-eco/releases/download/v$(PKG_VERSION)
PKG_HASH:=eef79d98e06b682f9fca1f84f164b949c493582e01adb775bfb1c2dbcf2e8b42

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
  DEPENDS:=+libev +liblua5.3
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
Package/lua-eco-base64=$(call Package/lua-eco/Module,base64)
Package/lua-eco-sha1=$(call Package/lua-eco/Module,sha1)
Package/lua-eco-md5=$(call Package/lua-eco/Module,md5)
Package/lua-eco-socket=$(call Package/lua-eco/Module,socket)
Package/lua-eco-dns=$(call Package/lua-eco/Module,dns,+lua-eco-socket)
Package/lua-eco-ssl=$(call Package/lua-eco/Module,ssl,\
  +LUA_ECO_OPENSSL:libopenssl +LUA_ECO_WOLFSSL:libwolfssl \
  +LUA_ECO_MBEDTLS:libmbedtls +LUA_ECO_MBEDTLS:zlib +lua-eco-socket)
Package/lua-eco-ubus=$(call Package/lua-eco/Module,ubus,+libubus)
Package/lua-eco-http=$(call Package/lua-eco/Module,http/https,+lua-eco-dns +lua-eco-ssl +lua-eco-base64 +lua-eco-log)
Package/lua-eco-mqtt=$(call Package/lua-eco/Module,mqtt,+lua-eco-socket +lua-eco-ssl)
Package/lua-eco-websocket=$(call Package/lua-eco/Module,websocket,+lua-eco-http +lua-eco-base64 +lua-eco-sha1)
Package/lua-eco-termios=$(call Package/lua-eco/Module,termios)
Package/lua-eco-netlink=$(call Package/lua-eco/Module,netlink,+lua-eco-socket)
Package/lua-eco-ip=$(call Package/lua-eco/Module,ip utils,+lua-eco-netlink)
Package/lua-eco-nl80211=$(call Package/lua-eco/Module,nl80211,+lua-eco-netlink)
Package/lua-eco-ssh=$(call Package/lua-eco/Module,ssh,+lua-eco-socket +libssh2)

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
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/local/lib/lua/5.3/eco/core \
		$(1)/usr/lib $(1)/usr/local/lib/lua/5.3/eco/encoding
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eco $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libeco.so $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bufio.so $(1)/usr/local/lib/lua/5.3/eco
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/hex.lua $(1)/usr/local/lib/lua/5.3/eco/encoding
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/{time,bufio,sys,file}.so $(1)/usr/local/lib/lua/5.3/eco/core
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/{time,sys,file,sync}.lua $(1)/usr/local/lib/lua/5.3/eco
endef

define Package/lua-eco-log/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.3/eco
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/log.so $(1)/usr/local/lib/lua/5.3/eco
endef

define Package/lua-eco-base64/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.3/eco/encoding
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/base64.so $(1)/usr/local/lib/lua/5.3/eco/encoding
endef

define Package/lua-eco-sha1/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.3/eco/hash
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sha1.so $(1)/usr/local/lib/lua/5.3/eco/hash
endef

define Package/lua-eco-md5/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.3/eco/hash
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/md5.so $(1)/usr/local/lib/lua/5.3/eco/hash
endef

define Package/lua-eco-socket/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.3/eco/core
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/socket.lua $(1)/usr/local/lib/lua/5.3/eco
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/socket.so $(1)/usr/local/lib/lua/5.3/eco/core
endef

define Package/lua-eco-dns/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.3/eco
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/dns.lua $(1)/usr/local/lib/lua/5.3/eco
endef

define Package/lua-eco-ssl/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.3/eco/core
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ssl.lua $(1)/usr/local/lib/lua/5.3/eco
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ssl.so $(1)/usr/local/lib/lua/5.3/eco/core
endef

define Package/lua-eco-ubus/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.3/eco/core
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ubus.lua $(1)/usr/local/lib/lua/5.3/eco
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ubus.so $(1)/usr/local/lib/lua/5.3/eco/core
endef

define Package/lua-eco-http/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.3/eco/http
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/http/*.lua $(1)/usr/local/lib/lua/5.3/eco/http
endef

define Package/lua-eco-mqtt/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.3/eco
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/mqtt.lua $(1)/usr/local/lib/lua/5.3/eco
endef

define Package/lua-eco-websocket/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.3/eco
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/websocket.lua $(1)/usr/local/lib/lua/5.3/eco
endef

define Package/lua-eco-termios/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.3/eco
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/termios.so $(1)/usr/local/lib/lua/5.3/eco
endef

define Package/lua-eco-netlink/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.3/eco/core
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/{nl,genl}.lua $(1)/usr/local/lib/lua/5.3/eco
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/{nl,genl}.so $(1)/usr/local/lib/lua/5.3/eco/core
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rtnl.so $(1)/usr/local/lib/lua/5.3/eco
endef

define Package/lua-eco-ip/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.3/eco
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ip.lua $(1)/usr/local/lib/lua/5.3/eco
endef

define Package/lua-eco-nl80211/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.3/eco/core
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/nl80211.lua $(1)/usr/local/lib/lua/5.3/eco
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nl80211.so $(1)/usr/local/lib/lua/5.3/eco/core
endef

define Package/lua-eco-ssh/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.3/eco/core
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ssh.lua $(1)/usr/local/lib/lua/5.3/eco
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ssh.so $(1)/usr/local/lib/lua/5.3/eco/core
endef

$(eval $(call BuildPackage,lua-eco))
$(eval $(call BuildPackage,lua-eco-log))
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
$(eval $(call BuildPackage,lua-eco-ssh))
