# SPDX-FileCopyrightText: 2022-2023 Stijn Tintel <stijn@linux-ipv6.be>
# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=openthread-br
PKG_VERSION:=2026.08.0
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/openthread/ot-br-posix.git
PKG_MIRROR_HASH:=4645fefcf89d0c06de87bbfa9e52e2a522de48fa52146427669323c894405eb9

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
  DEPENDS:=+luci-base +luci-lua-runtime
endef

define Package/openthread-br
  CATEGORY:=Network
  SECTION:=net
  TITLE:=OpenThread Border Router
  DEPENDS:= \
	+kmod-tun \
	+libblobmsg-json \
	+libjson-c \
	+cJSON \
	+libncurses \
	+libnetfilter-queue \
	+libreadline \
	+libstdcpp \
	+libubox \
	+libubus
endef

define Package/openthread-br/description
  A Thread border router for POSIX-based platforms.
endef

define Package/openthread-br/conffiles
/var/lib/thread
endef

CMAKE_OPTIONS += \
	-DOT_BORDER_ROUTER=ON \
	-DOT_CHANNEL_MANAGER=ON \
	-DOT_CHANNEL_MONITOR=ON \
	-DOT_FIREWALL=OFF \
	-DOT_NAT64_BORDER_ROUTING=OFF \
	-DOT_TARGET_OPENWRT=ON \
	-DOTBR_BACKBONE_ROUTER=ON \
	-DOTBR_BORDER_ROUTING=ON \
	-DOTBR_MDNS=openthread \
	-DOTBR_NAT64=OFF \
	-DOTBR_OPENWRT=ON \
	-DOTBR_PRODUCT_NAME=BorderRouter \
	-DOTBR_REST=ON \
	-DOTBR_SRP_SERVER_AUTO_ENABLE=ON \
	-DOTBR_TREL=ON \
	-DOTBR_VENDOR_NAME=OpenThread \
	-DOTBR_VERSION=$(PKG_VERSION)

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
		$(1)/etc/hotplug.d/usb \
		$(1)/etc/init.d \
		$(1)/lib/netifd/proto \
		$(1)/usr/sbin
	$(INSTALL_BIN) ./files/openthread-proto.sh $(1)/lib/netifd/proto/openthread.sh
	$(INSTALL_BIN) ./files/otbr-rcp $(1)/usr/sbin
	$(INSTALL_DATA) ./files/otbr-rcp.hotplug $(1)/etc/hotplug.d/usb/50-otbr-rcp
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin
endef


$(eval $(call BuildPackage,luci-app-openthread))
$(eval $(call BuildPackage,openthread-br))
