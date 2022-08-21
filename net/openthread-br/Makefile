# SPDX-FileCopyrightText: 2022 Stijn Tintel <stijn@linux-ipv6.be>
# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=openthread-br
PKG_SOURCE_DATE:=2022-08-12
PKG_SOURCE_VERSION:=7a1bb4df86f9ce0fc26a16b8a5adaa16bf8d1e99
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/openthread/ot-br-posix.git
PKG_MIRROR_HASH:=3c517762943b192c50be34cac218133253a16596f711520b552b724822770c6e

#PKG_BUILD_DIR:=$(BUILD_DIR)/ot-br-posix-thread-br-certified-$(PKG_VERSION)

PKG_MAINTAINER:=Stijn Tintel <stijn@linux-ipv6.be>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/openthread-br
  SECTION:=net
  CATEGORY:=Network
  TITLE:=OpenThread Border Router
  DEPENDS:= \
	+libavahi-client \
	+libblobmsg-json \
	+libjson-c \
	+libncurses \
	+libreadline \
	+libstdcpp \
	+libubox \
	+libubus
endef

define Package/openthread-br/description
  A Thread border router for POSIX-based platforms.
endef

define Package/openthread-br/conffiles
/etc/config/openthread
endef

CMAKE_OPTIONS += \
	-DOT_BACKBONE_ROUTER:BOOL=ON \
	-DOT_BORDER_ROUTER:BOOL=ON \
	-DOT_BORDER_ROUTING:BOOL=ON \
	-DOT_BORDER_ROUTING_NAT64:BOOL=ON \
	-DOT_CHANNEL_MANAGER:BOOL=ON \
	-DOT_CHANNEL_MONITOR:BOOL=ON \
	-DOT_COMMISSIONER:BOOL=ON \
	-DOT_SERVICE:BOOL=ON \
	-DOT_TREL:BOOL=ON \
	-DOTBR_OPENWRT:BOOL=ON

define Package/openthread-br/install
	$(INSTALL_DIR) \
		$(1)/etc/config $(1)/etc/init.d \
		$(1)/usr/lib/lua/luci/controller/admin \
		$(1)/usr/lib/lua/luci/view/admin_thread $(1)/usr/sbin \
		$(1)/www/luci-static/resources
	$(INSTALL_CONF) ./files/openthread.conf $(1)/etc/config/openthread
	$(INSTALL_BIN) ./files/otbr-agent.init $(1)/etc/init.d/otbr-agent
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/src/openwrt/controller/thread.lua \
		$(1)/usr/lib/lua/luci/controller/admin
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/src/openwrt/view/admin_thread/* \
		$(1)/usr/lib/lua/luci/view/admin_thread
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/src/openwrt/handle_error.js \
		$(1)/www/luci-static/resources
endef


$(eval $(call BuildPackage,openthread-br))
