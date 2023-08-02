include $(TOPDIR)/rules.mk

PKG_NAME:=snode.c
PKG_VERSION:=0.99
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/VolkerChristian/snode.c.git
#PKG_SOURCE_VERSION:=70a947a6f60f3dacfd5d8f7d5cc8ae7b285825ac
PKG_SOURCE_VERSION:=HEAD
PKG_SOURCE_DATE:=2023-07-02
#PKG_MIRROR_HASH:=856ff2c73fca4b22ad1997d804600a026f8d3e85716ed3a9a97cc0c7e282a539
PKG_MIRROR_HASH:=skip

PKG_MAINTAINER:=Volker Christian <me@vchrist.at>
PKG_LICENSE:=LGPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=nlohmannjson easyloggingpp

CMAKE_INSTALL:=1

GROUP_NAME:=snodec

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
                 -DCMAKE_SKIP_RPATH=FALSE
                 
define Package/snode.c/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=https://github.com/VolkerChristian/snode.c
  Maintainer:=Volker Christian <me@vchrist.at>
endef

define Package/snode.c/description
  SNode.C is a very simple to use lightweight highly extendable event
  driven layer-based framework for network applications in the spirit
  of node.js written entirely in C++.
endef

define Package/snode.c
  $(call Package/snode.c/Default)
  MENU:=1
  TITLE:=Easy to use lightwight layer based network framework for C++
  DEPENDS:=+libopenssl +libmagic +libstdcpp +bluez-libs +libmariadb
endef

define Package/snode.c/config
  source "$(SOURCE)/Config.in"
endef

define Package/snode.c/install
	true
endef

define Package/snode.c/postinst
#!/bin/sh

GROUP_NAME=$(GROUP_NAME)
GROUP_ID=$(call qstrip,$(SNODEC_GROUP_ID))

if [ -z "$$(grep ^$${GROUP_NAME}: $${IPKG_INSTROOT}/etc/group)" ]; then
	echo "Adding group $${GROUP_NAME} to /etc/group and assign user root to it"
	echo "$${GROUP_NAME}:x:$${GROUP_ID}:root" >> $${IPKG_INSTROOT}/etc/group
fi
endef

define Package/snode.c/prerm
#!/bin/sh

GROUP_NAME=$(GROUP_NAME)

echo "Removing group $${GROUP_NAME} from /etc/group"
sed -i "/^$${GROUP_NAME}:/d" /etc/group
endef

define BuildSNodeCModule
  define Package/snode.c-$(1)
    $$(call Package/snode.c/Default)
    TITLE:=$(1) module
    DEPENDS:=snode.c $(2)
  endef

  define Package/snode.c-$(1)/install
	$(INSTALL_DIR) $$(1)$(3)
	$(CP) $(PKG_INSTALL_DIR)$(3)/libsnodec-$(1).so.1 $$(1)$(3)/ || :
  endef

  $$(eval $$(call BuildPackage,snode.c-$(1)))
endef

define Package/snode.c-full
  $(call Package/snode.c/Default)
  TITLE:=all modules in one package
  DEPENDS:=snode.c
  PROVIDES:=snode.c-core \
	snode.c-core-mux-epoll \
	snode.c-core-mux-poll \
	snode.c-core-mux-select \
	snode.c-core-socket \
	snode.c-core-socket-stream \
	snode.c-core-socket-stream-legacy \
	snode.c-core-socket-stream-tls \
	snode.c-db-mariadb \
	snode.c-http \
	snode.c-http-client \
	snode.c-http-server \
	snode.c-http-server-express \
	snode.c-logger \
	snode.c-mqtt \
	snode.c-mqtt-client \
	snode.c-mqtt-server \
	snode.c-net \
	snode.c-net-in \
	snode.c-net-in6 \
	snode.c-net-in6-stream \
	snode.c-net-in6-stream-legacy \
	snode.c-net-in6-stream-tls \
	snode.c-net-in-stream \
	snode.c-net-in-stream-legacy \
	snode.c-net-in-stream-tls \
	snode.c-net-l2 \
	snode.c-net-l2-stream \
	snode.c-net-l2-stream-legacy \
	snode.c-net-l2-stream-tls \
	snode.c-net-rc \
	snode.c-net-rc-stream \
	snode.c-net-rc-stream-legacy \
	snode.c-net-rc-stream-tls \
	snode.c-net-un \
	snode.c-net-un-dgram \
	snode.c-net-un-stream \
	snode.c-net-un-stream-legacy \
	snode.c-net-un-stream-tls \
	snode.c-utils \
	snode.c-websocket \
	snode.c-websocket-client \
	snode.c-websocket-server
endef

define Package/snode.c-full/description
 This meta-package contains dependencies for all of the snode.c modules.
 Note that the demo applications are not part of that dependency.
endef

define Package/snode.c-apps
  $(call Package/snode.c/Default)
  TITLE:=SNode.C demo applications
  DEPENDS:=snode.c \
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
	+snode.c-http-server-express \
	+snode.c-http-client \
	+snode.c-websocket-server \
	+snode.c-websocket-client \
	+snode.c-mqtt-server \
	+snode.c-mqtt-client \
	+snode.c-db-mariadb
endef

define Package/snode.c-apps/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/snode.c/web/http/upgrade/websocket
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/snode.c/web/http/upgrade/websocket/libsnodec-websocket-echo-server.so.1 $(1)/usr/lib/snode.c/web/http/upgrade/websocket/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/snode.c/web/http/upgrade/websocket/libsnodec-websocket-echo-client.so.1 $(1)/usr/lib/snode.c/web/http/upgrade/websocket/
endef

$(eval $(call BuildPackage,snode.c))
$(eval $(call BuildPackage,snode.c-apps))
$(eval $(call BuildSNodeCModule,logger,+libstdcpp,/usr/lib))
$(eval $(call BuildSNodeCModule,utils,+snode.c-logger,/usr/lib))
$(eval $(call BuildSNodeCModule,core-mux-epoll,+snode.c-logger,/usr/lib))
$(eval $(call BuildSNodeCModule,core-mux-poll,+snode.c-logger,/usr/lib))
$(eval $(call BuildSNodeCModule,core-mux-select,+snode.c-logger,/usr/lib))
$(eval $(call BuildSNodeCModule,core,+snode.c-utils +snode.c-core-mux-epoll,/usr/lib))
$(eval $(call BuildSNodeCModule,core-socket,+snode.c-core,/usr/lib))
$(eval $(call BuildSNodeCModule,core-socket-stream,+snode.c-core-socket,/usr/lib))
$(eval $(call BuildSNodeCModule,core-socket-stream-legacy,+snode.c-core-socket-stream,/usr/lib))
$(eval $(call BuildSNodeCModule,core-socket-stream-tls,+snode.c-core-socket-stream +libopenssl,/usr/lib))
$(eval $(call BuildSNodeCModule,db-mariadb,+snode.c-core +libmariadb,/usr/lib))
$(eval $(call BuildSNodeCModule,net,+snode.c-core,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in,+snode.c-net +snode.c-core-socket,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in6,+snode.c-net +snode.c-core-socket,/usr/lib))
$(eval $(call BuildSNodeCModule,net-l2,+snode.c-net +snode.c-core-socket +bluez-libs,/usr/lib))
$(eval $(call BuildSNodeCModule,net-rc,+snode.c-net +snode.c-core-socket +bluez-libs,/usr/lib))
$(eval $(call BuildSNodeCModule,net-un,+snode.c-net +snode.c-core-socket,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in-stream,+snode.c-net-in,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in6-stream,+snode.c-net-in6,/usr/lib))
$(eval $(call BuildSNodeCModule,net-l2-stream,+snode.c-net-l2,/usr/lib))
$(eval $(call BuildSNodeCModule,net-rc-stream,+snode.c-net-rc,/usr/lib))
$(eval $(call BuildSNodeCModule,net-un-stream,+snode.c-net-un,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in-stream-legacy,+snode.c-net-in-stream +snode.c-core-socket-stream-legacy,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in6-stream-legacy,+snode.c-net-in6-stream +snode.c-core-socket-stream-legacy,/usr/lib))
$(eval $(call BuildSNodeCModule,net-l2-stream-legacy,+snode.c-net-l2-stream +snode.c-core-socket-stream-legacy,/usr/lib))
$(eval $(call BuildSNodeCModule,net-rc-stream-legacy,+snode.c-net-rc-stream +snode.c-core-socket-stream-legacy,/usr/lib))
$(eval $(call BuildSNodeCModule,net-un-stream-legacy,+snode.c-net-un-stream +snode.c-core-socket-stream-legacy,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in-stream-tls,+snode.c-net-in-stream +snode.c-core-socket-stream-tls,/usr/lib))
$(eval $(call BuildSNodeCModule,net-in6-stream-tls,+snode.c-net-in6-stream +snode.c-core-socket-stream-tls,/usr/lib))
$(eval $(call BuildSNodeCModule,net-l2-stream-tls,+snode.c-net-l2-stream +snode.c-core-socket-stream-tls,/usr/lib))
$(eval $(call BuildSNodeCModule,net-rc-stream-tls,+snode.c-net-rc-stream +snode.c-core-socket-stream-tls,/usr/lib))
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
$(eval $(call BuildPackage,snode.c-full))
