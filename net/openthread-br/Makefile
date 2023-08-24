# SPDX-FileCopyrightText: 2022-2023 Stijn Tintel <stijn@linux-ipv6.be>
# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=openthread-br
PKG_SOURCE_DATE:=2023-08-01
PKG_SOURCE_VERSION:=1738d8cd8b42106c2ef1262fbbac2f06beab83ba
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/openthread/ot-br-posix.git
PKG_MIRROR_HASH:=7eb740d1a0663aae7969940f8a8b06879524dd62ae7842f46a160cae54ee8417

PKG_MAINTAINER:=Stijn Tintel <stijn@linux-ipv6.be>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/luci-app-openthread
  CATEGORY:=LuCI
  SECTION:=luci
  SUBMENU:=3. Applications
  TITLE:=LuCI Support for OpenThread Border Router
  DEPENDS:=+luci-base
endef

define Package/openthread-br
  CATEGORY:=Network
  SECTION:=net
  TITLE:=OpenThread Border Router
  DEPENDS:= \
	+libblobmsg-json \
	+libjson-c \
	+libncurses \
	+libnetfilter-queue \
	+libreadline \
	+libstdcpp \
	+libubox \
	+libubus \
	+mdnsd \
	+mdnsresponder
endef

define Package/openthread-br/description
  A Thread border router for POSIX-based platforms.
endef

define Package/openthread-br/conffiles
/var/lib/thread
endef

CMAKE_OPTIONS += \
	-DOT_BORDER_ROUTER:BOOL=ON \
	-DOT_BORDER_ROUTING_NAT64:BOOL=ON \
	-DOT_CHANNEL_MANAGER:BOOL=ON \
	-DOT_CHANNEL_MONITOR:BOOL=ON \
	-DOT_COMMISSIONER:BOOL=ON \
	-DOT_ECDSA:BOOL=ON \
	-DOT_FIREWALL:BOOL=OFF \
	-DOT_SERVICE:BOOL=ON \
	-DOT_SRP_CLIENT:BOOL=ON \
	-DOT_SRP_SERVER:BOOL=ON \
	-DOTBR_BACKBONE_ROUTER:BOOL=ON \
	-DOTBR_BORDER_ROUTING:BOOL=ON \
	-DOTBR_DNSSD_DISCOVERY_PROXY:BOOL=ON \
	-DOTBR_DUA_ROUTING:BOOL=ON \
	-DOTBR_MDNS=mDNSResponder \
	-DOTBR_OPENWRT:BOOL=ON \
	-DOTBR_REST:BOOL=ON \
	-DOTBR_SRP_ADVERTISING_PROXY:BOOL=ON \
	-DOTBR_SRP_SERVER_AUTO_ENABLE:BOOL=ON \
	-DOTBR_TREL:BOOL=ON

TARGET_CFLAGS += -DOPENTHREAD_POSIX_CONFIG_DAEMON_SOCKET_BASENAME=\\\"/var/run/openthread-%s\\\"

define Package/luci-app-openthread/install
	$(INSTALL_DIR) \
		$(1)/usr/lib/lua/luci/controller/admin \
		$(1)/usr/lib/lua/luci/view/admin_thread \
		$(1)/www/luci-static/resources
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/src/openwrt/controller/thread.lua \
		$(1)/usr/lib/lua/luci/controller/admin
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/src/openwrt/view/admin_thread/* \
		$(1)/usr/lib/lua/luci/view/admin_thread
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/src/openwrt/handle_error.js \
		$(1)/www/luci-static/resources
endef

define Package/openthread-br/install
	$(INSTALL_DIR) \
		$(1)/etc/init.d \
		$(1)/lib/netifd/proto \
		$(1)/usr/sbin \
		$(1)/var/lib/thread
	$(INSTALL_BIN) ./files/openthread-proto.sh $(1)/lib/netifd/proto/openthread.sh
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin
endef


$(eval $(call BuildPackage,luci-app-openthread))
$(eval $(call BuildPackage,openthread-br))
