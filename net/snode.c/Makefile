include $(TOPDIR)/rules.mk

PKG_NAME:=snode.c
PKG_VERSION:=0.90
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/SNodeC/snode.c/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=dd26d3fb6232c19212b9bf5cc5e3fd9ab3a45a5142e0590771c8fe34568c16c3

# PKG_SOURCE_URL:=https://api.github.com/repos/SNodeC/snode.c/tarball/v$(PKG_VERSION)?
# PKG_HASH:=2df9a5086264a4f6034c18cd0fc9dfe3e6cfe7abb5a129c9a84793f23e528b5f

PKG_MAINTAINER:=Volker Christian <me@vchrist.at>
PKG_LICENSE:=LGPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=nlohmannjson easyloggingpp
PKG_BUILD_PARALLEL:=1

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

ifdef CONFIG_SNODEC_EPOLL
  CONFIG_SNODEC_IO_MULTIPLEXER=epoll
else ifdef CONFIG_SNODEC_POLL
  CONFIG_SNODEC_IO_MULTIPLEXER=poll
else ifdef CONFIG_SNODEC_SELECT
  CONFIG_SNODEC_IO_MULTIPLEXER=select
endif

CMAKE_OPTIONS+=-DGROUP_NAME=$(patsubst "%",%,$(CONFIG_SNODEC_GROUP_NAME)) \
               -DIO_MULTIPLEXER=$(CONFIG_SNODEC_IO_MULTIPLEXER) \
               -DREAD_BLOCKSIZE=$(CONFIG_SNODEC_READ_BLOCKSIZE) \
               -DWRITE_BLOCKSIZE=$(CONFIG_SNODEC_WRITE_BLOCKSIZE) \
               -DREAD_TIMEOUT=$(CONFIG_SNODEC_READ_TIMEOUT) \
               -DWRITE_TIMEOUT=$(CONFIG_SNODEC_WRITE_TIMEOUT) \
               -DTERMINATE_TIMEOUT=$(CONFIG_SNODEC_TERMINATE_TIMEOUT) \
               -DBACKLOG=$(CONFIG_SNODEC_BACKLOG) \
               -DACCEPTS_PER_TICK=$(CONFIG_SNODEC_ACCEPTS_PER_TICK) \
               -DREUSE_ADDRESS=$(CONFIG_SNODEC_REUSE_ADDRESS) \
               -DREUSE_PORT=$(CONFIG_SNODEC_REUSE_PORT) \
               -DIPV6_ONLY=$(CONFIG_SNODEC_IPV6_ONLY) \
               -DIPV4_MAPPED=$(CONFIG_SNODEC_IPV4_MAPPED) \
               -DACCEPT_TIMEOUT=$(CONFIG_SNODEC_ACCEPT_TIMEOUT) \
               -DCONNECT_TIMEOUT=$(CONFIG_SNODEC_CONNECT_TIMEOUT) \
               -DRECONNECT=$(CONFIG_SNODEC_RECONNECT) \
               -DRECONNECT_TIME=$(CONFIG_SNODEC_RECONNECT_TIME) \
               -DRETRY=$(CONFIG_SNODEC_RETRY) \
               -DRETRY_TIMEOUT=$(CONFIG_SNODEC_RETRY_TIMEOUT) \
               -DRETRY_TRIES=$(CONFIG_SNODEC_RETRY_TRIES) \
               -DRETRY_BASE=$(CONFIG_SNODEC_RETRY_BASE) \
               -DRETRY_JITTER=$(CONFIG_SNODEC_RETRY_JITTER) \
               -DRETRY_LIMIT=$(CONFIG_SNODEC_RETRY_LIMIT) \
               -DTLS_INIT_TIMEOUT=$(CONFIG_SNODEC_TLS_INIT_TIMEOUT) \
               -DTLS_SHUTDOWN_TIMEOUT=$(CONFIG_SNODEC_TLS_SHUTDOWN_TIMEOUT) \
               -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
               -DCMAKE_SKIP_RPATH=FALSE

define Package/snode.c/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=SNode.C
endef

define Package/snode.c
  $(call Package/snode.c/Default)
  TITLE:=Easy to use lightwight layer based network framework for C++
  DEPENDS:=+libstdcpp
  USERID:=$(patsubst "%",%,$(CONFIG_SNODEC_GROUP_NAME)):$(patsubst "%",%,$(CONFIG_SNODEC_GROUP_NAME))
endef

define Package/snode.c/description
  SNode.C is a very simple to use lightweight highly extendable event
driven layer-based framework for network applications in the spirit
of node.js written entirely in C++.

endef

define Package/snode.c/config
  source "$(SOURCE)/Config.in"
endef

define Package/snode.c/install
	true
endef

SO_VERSION=$(shell echo $(PKG_VERSION) | cut -d'.' -f1)

define BuildSNodeCModule
  define Package/snode.c-$(1)
    $$(call Package/snode.c/Default)
    TITLE:=$(1) module
    DEPENDS:=$(2)
  endef

  define Package/snode.c-$(1)/description
    This package contains the module '$(1)' of SNode.C

  endef
  
  define Package/snode.c-$(1)/install
	$(INSTALL_DIR) $$(1)$(3)
	$(CP) $(PKG_INSTALL_DIR)$(3)/libsnodec-$(1).so.$(SO_VERSION) $$(1)$(3)/ 2> /dev/null || true
  endef

  $$(eval $$(call BuildPackage,snode.c-$(1)))
endef

define Package/snode.c-full
  $(call Package/snode.c/Default)
  TITLE:=install all modules (no apps)
  DEPENDS:=+snode.c-core-mux-epoll \
           +snode.c-core-mux-poll \
           +snode.c-core-mux-select \
           +snode.c-net-in-stream-legacy \
           +snode.c-net-in-stream-tls \
           +snode.c-net-in6-stream-legacy \
           +snode.c-net-in6-stream-tls \
           +snode.c-net-l2-stream-legacy \
           +snode.c-net-l2-stream-tls \
           +snode.c-net-rc-stream-legacy \
           +snode.c-net-rc-stream-tls \
           +snode.c-net-un-stream-legacy \
           +snode.c-net-un-stream-tls \
           +snode.c-net-un-dgram \
           +snode.c-http-server-express \
           +snode.c-http-client \
           +snode.c-websocket-server \
           +snode.c-websocket-client \
           +snode.c-mqtt-server-websocket \
           +snode.c-mqtt-client-websocket \
           +snode.c-db-mariadb
endef

define Package/snode.c-full/description
 This meta-package contains dependencies for all of the SNode.C modules.
Note that the demo applications are not part of that dependency.

endef

define Package/snode.c-full/install
	true
endef

define Package/snode.c-apps
  $(call Package/snode.c/Default)
  TITLE:=SNode.C demo applications
  DEPENDS:=+snode.c-net-in-stream-legacy \
           +snode.c-net-in-stream-tls \
           +snode.c-net-in6-stream-legacy \
           +snode.c-net-in6-stream-tls \
           +snode.c-net-l2-stream-legacy \
           +snode.c-net-l2-stream-tls \
           +snode.c-net-rc-stream-legacy \
           +snode.c-net-rc-stream-tls \
           +snode.c-net-un-stream-legacy \
           +snode.c-net-un-stream-tls \
           +snode.c-http-server-express \
           +snode.c-http-client \
           +snode.c-websocket-server \
           +snode.c-websocket-client \
           +snode.c-mqtt-server \
           +snode.c-mqtt-client \
           +snode.c-db-mariadb
endef

define Package/snode.c-apps/description
 This package contains all demo applications of SNode.C.

endef

define Package/snode.c-apps/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/snode.c/web/http/upgrade/websocket
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/snode.c/web/http/upgrade/websocket/libsnodec-websocket-echo-server.so.$(SO_VERSION) $(1)/usr/lib/snode.c/web/http/upgrade/websocket/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/snode.c/web/http/upgrade/websocket/libsnodec-websocket-echo-client.so.$(SO_VERSION) $(1)/usr/lib/snode.c/web/http/upgrade/websocket/
endef

ifdef CONFIG_SNODEC_IO_MULTIPLEXER
  CONFIG_SNODEC_IO_MULTIPLEXER_DEPENDENCY:=+snode.c-core-mux-$(CONFIG_SNODEC_IO_MULTIPLEXER)
endif

$(eval $(call BuildPackage,snode.c))
$(eval $(call BuildPackage,snode.c-apps))
$(eval $(call BuildPackage,snode.c-full))
$(eval $(call BuildSNodeCModule,logger,snode.c,/usr/lib))
$(eval $(call BuildSNodeCModule,utils,+snode.c-logger,/usr/lib))
$(eval $(call BuildSNodeCModule,core-mux-epoll,+snode.c-logger,/usr/lib))
$(eval $(call BuildSNodeCModule,core-mux-poll,+snode.c-logger,/usr/lib))
$(eval $(call BuildSNodeCModule,core-mux-select,+snode.c-logger,/usr/lib))
$(eval $(call BuildSNodeCModule,core,+snode.c-utils $(CONFIG_SNODEC_IO_MULTIPLEXER_DEPENDENCY),/usr/lib))
$(eval $(call BuildSNodeCModule,core-socket,+snode.c-core,/usr/lib))
$(eval $(call BuildSNodeCModule,core-socket-stream,+snode.c-core-socket,/usr/lib))
$(eval $(call BuildSNodeCModule,core-socket-stream-legacy,+snode.c-core-socket-stream,/usr/lib))
$(eval $(call BuildSNodeCModule,core-socket-stream-tls,+snode.c-core-socket-stream +libopenssl,/usr/lib))
$(eval $(call BuildSNodeCModule,db-mariadb,+snode.c-core +libmariadb,/usr/lib))
$(eval $(call BuildSNodeCModule,net,+snode.c-utils,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in,+snode.c-net,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in-phy,+snode.c-net-in,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in-phy-stream,+snode.c-net-in-phy,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in-stream,+snode.c-net-in-phy-stream,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in-stream-legacy,+snode.c-net-in-stream +snode.c-core-socket-stream-legacy,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in-stream-tls,+snode.c-net-in-stream +snode.c-core-socket-stream-tls,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in6,+snode.c-net,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in6-phy,+snode.c-net-in6,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in6-phy-stream,+snode.c-net-in6-phy,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in6-stream,+snode.c-net-in6-phy-stream,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in6-stream-legacy,+snode.c-net-in6-stream +snode.c-core-socket-stream-legacy,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in6-stream-tls,+snode.c-net-in6-stream +snode.c-core-socket-stream-tls,/usr/lib))
$(eval $(call BuildSNodeCModule,net-l2,+snode.c-net,/usr/lib))
$(eval $(call BuildSNodeCModule,net-l2-phy,+snode.c-net-l2 +bluez-libs,/usr/lib))
$(eval $(call BuildSNodeCModule,net-l2-phy-stream,+snode.c-net-l2-phy,/usr/lib))
$(eval $(call BuildSNodeCModule,net-l2-stream,+snode.c-net-l2-phy-stream,/usr/lib))
$(eval $(call BuildSNodeCModule,net-l2-stream-legacy,+snode.c-net-l2-stream +snode.c-core-socket-stream-legacy,/usr/lib))
$(eval $(call BuildSNodeCModule,net-l2-stream-tls,+snode.c-net-l2-stream +snode.c-core-socket-stream-tls,/usr/lib))
$(eval $(call BuildSNodeCModule,net-rc,+snode.c-net,/usr/lib))
$(eval $(call BuildSNodeCModule,net-rc-phy,+snode.c-net-rc +bluez-libs,/usr/lib))
$(eval $(call BuildSNodeCModule,net-rc-phy-stream,+snode.c-net-rc-phy,/usr/lib))
$(eval $(call BuildSNodeCModule,net-rc-stream,+snode.c-net-rc-phy-stream,/usr/lib))
$(eval $(call BuildSNodeCModule,net-rc-stream-legacy,+snode.c-net-rc-stream +snode.c-core-socket-stream-legacy,/usr/lib))
$(eval $(call BuildSNodeCModule,net-rc-stream-tls,+snode.c-net-rc-stream +snode.c-core-socket-stream-tls,/usr/lib))
$(eval $(call BuildSNodeCModule,net-un,+snode.c-net,/usr/lib))
$(eval $(call BuildSNodeCModule,net-un-phy,+snode.c-net-un,/usr/lib))
$(eval $(call BuildSNodeCModule,net-un-phy-stream,+snode.c-net-un-phy,/usr/lib))
$(eval $(call BuildSNodeCModule,net-un-stream,+snode.c-net-un-phy-stream,/usr/lib))
$(eval $(call BuildSNodeCModule,net-un-stream-legacy,+snode.c-net-un-stream +snode.c-core-socket-stream-legacy,/usr/lib))
$(eval $(call BuildSNodeCModule,net-un-stream-tls,+snode.c-net-un-stream +snode.c-core-socket-stream-tls,/usr/lib))
$(eval $(call BuildSNodeCModule,net-un-dgram,+snode.c-net-un,/usr/lib))
$(eval $(call BuildSNodeCModule,http,+snode.c-core-socket-stream +libmagic,/usr/lib/snode.c/web/http))
$(eval $(call BuildSNodeCModule,http-server,+snode.c-http,/usr/lib/snode.c/web/http))
$(eval $(call BuildSNodeCModule,http-client,+snode.c-http,/usr/lib/snode.c/web/http))
$(eval $(call BuildSNodeCModule,http-server-express,+snode.c-http-server,/usr/lib/snode.c/web/http))
$(eval $(call BuildSNodeCModule,websocket,+snode.c-logger,/usr/lib/snode.c/web/http/upgrade))
$(eval $(call BuildSNodeCModule,websocket-server,+snode.c-websocket +snode.c-http-server,/usr/lib/snode.c/web/http/upgrade))
$(eval $(call BuildSNodeCModule,websocket-client,+snode.c-websocket +snode.c-http-client,/usr/lib/snode.c/web/http/upgrade))
$(eval $(call BuildSNodeCModule,mqtt,+snode.c-core-socket-stream,/usr/lib/snode.c/iot/mqtt))
$(eval $(call BuildSNodeCModule,mqtt-server,+snode.c-mqtt,/usr/lib/snode.c/iot/mqtt))
$(eval $(call BuildSNodeCModule,mqtt-client,+snode.c-mqtt,/usr/lib/snode.c/iot/mqtt))
$(eval $(call BuildSNodeCModule,mqtt-server-websocket,+snode.c-mqtt-server +snode.c-websocket-server,/usr/lib/snode.c/iot/mqtt))
$(eval $(call BuildSNodeCModule,mqtt-client-websocket,+snode.c-mqtt-client +snode.c-websocket-client,/usr/lib/snode.c/iot/mqtt))
