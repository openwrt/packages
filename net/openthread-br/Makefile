# SPDX-FileCopyrightText: 2022-2023 Stijn Tintel <stijn@linux-ipv6.be>
# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=openthread-br
PKG_VERSION:=2026.09.0
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/openthread/ot-br-posix.git
PKG_MIRROR_HASH:=d0c82691b95e0aa2112ca08f6ff544c23794eae632c8c01b040616a0d60f5aab

PKG_MAINTAINER:=Stijn Tintel <stijn@linux-ipv6.be>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

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
	-DOT_BORDER_ROUTER=ON \
	-DOT_CHANNEL_MANAGER=ON \
	-DOT_CHANNEL_MONITOR=ON \
	-DOT_FIREWALL=OFF \
	-DOT_NAT64_BORDER_ROUTING=OFF \
	-DOT_TARGET_OPENWRT=ON \
	-DOTBR_BACKBONE_ROUTER=ON \
	-DOTBR_BORDER_ROUTING=ON \
	-DOTBR_MDNS=mDNSResponder \
	-DOTBR_NAT64=OFF \
	-DOTBR_OPENWRT=ON \
	-DOTBR_PRODUCT_NAME=BorderRouter \
	-DOTBR_REST=ON \
	-DOTBR_SRP_SERVER_AUTO_ENABLE=ON \
	-DOTBR_TREL=ON \
	-DOTBR_VENDOR_NAME=OpenThread \
	-DOTBR_VERSION=$(PKG_VERSION)

TARGET_CFLAGS += -DOPENTHREAD_POSIX_CONFIG_DAEMON_SOCKET_BASENAME=\\\"/var/run/openthread-%s\\\"

define Package/openthread-br/install
	$(INSTALL_DIR) \
		$(1)/etc/init.d \
		$(1)/lib/netifd/proto \
		$(1)/usr/sbin
	$(INSTALL_BIN) ./files/openthread-proto.sh $(1)/lib/netifd/proto/openthread.sh
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin
endef


$(eval $(call BuildPackage,openthread-br))
