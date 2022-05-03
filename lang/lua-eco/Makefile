include $(TOPDIR)/rules.mk

PKG_NAME:=lua-eco
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL=https://github.com/zhaojh329/lua-eco/releases/download/v$(PKG_VERSION)
PKG_HASH:=136cf5643ec36ed472d332200e944c20853b9d335d8ebe2067ccc495923846d6

PKG_MAINTAINER:=Jianhui Zhao <zhaojh329@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

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
  +PACKAGE_libopenssl:libopenssl +PACKAGE_libwolfssl:libwolfssl +PACKAGE_libmbedtls:libmbedtls +PACKAGE_libmbedtls:zlib)
Package/lua-eco-iw=$(call Package/lua-eco/Module,IW utils,+libmnl)
Package/lua-eco-ip=$(call Package/lua-eco/Module,IP utils,+libmnl)
Package/lua-eco-file=$(call Package/lua-eco/Module,File utils)
Package/lua-eco-ubus=$(call Package/lua-eco/Module,Ubus,+libubus)

ifeq ($(CONFIG_PACKAGE_lua-eco-log),)
  CMAKE_OPTIONS += -DECO_LOG_SUPPORT=OFF
endif

ifeq ($(CONFIG_PACKAGE_lua-eco-sys),)
  CMAKE_OPTIONS += -DECO_SYS_SUPPORT=OFF
endif

ifeq ($(CONFIG_PACKAGE_lua-eco-dns),)
  CMAKE_OPTIONS += -DECO_DNS_SUPPORT=OFF
endif

ifeq ($(CONFIG_PACKAGE_lua-eco-socket),)
  CMAKE_OPTIONS += -DECO_SOCKET_SUPPORT=OFF
endif

ifeq ($(CONFIG_PACKAGE_lua-eco-ssl),)
  CMAKE_OPTIONS += -DECO_SSL_SUPPORT=OFF
else
ifneq ($(CONFIG_PACKAGE_libopenssl),)
  CMAKE_OPTIONS += -DUSE_OPENSSL=ON
else
  ifneq ($(CONFIG_PACKAGE_libwolfssl),)
    CMAKE_OPTIONS += -DUSE_WOLFSSL=ON
  else
    ifneq ($(CONFIG_PACKAGE_libmbedtls),)
      CMAKE_OPTIONS += -DUSE_MBEDTLS=ON
    endif
  endif
endif
endif

ifeq ($(CONFIG_PACKAGE_lua-eco-iw),)
  CMAKE_OPTIONS += -DECO_IW_SUPPORT=OFF
endif

ifeq ($(CONFIG_PACKAGE_lua-eco-ip),)
  CMAKE_OPTIONS += -DECO_IP_SUPPORT=OFF
endif

ifeq ($(CONFIG_PACKAGE_lua-eco-file),)
  CMAKE_OPTIONS += -DECO_FILE_SUPPORT=OFF
endif

ifeq ($(CONFIG_PACKAGE_lua-eco-ubus),)
  CMAKE_OPTIONS += -DECO_UBUS_SUPPORT=OFF
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
