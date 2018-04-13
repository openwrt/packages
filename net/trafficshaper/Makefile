#
# Copyright (C) 2018 Luiz Angelo Daros de Luca
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=trafficshaper
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Luiz Angelo Daros de Luca <luizluca@gmail.com>
PKG_LICENSE:=GPLv2
PKG_ARCH:=all

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
include $(INCLUDE_DIR)/package.mk

include $(INCLUDE_DIR)/package.mk

define Package/trafficshaper
   SECTION:=net
   CATEGORY:=Network
   DEPENDS:=+tc +kmod-sched-core +kmod-sched-connmark +kmod-ifb +iptables +kmod-sched-cake +iptables-mod-conntrack-extra
   TITLE:=WAN traffic shaper based on LAN addresses
   MAINTAINER:=Luiz Angelo Daros de Luca <luizluca@gmail.com>
   PKGARCH:=all
endef

define Package/trafficshaper/description
Setup QoS rules to limit (or reserve) traffic used by classes of clients.
Uplink and downlink can be controled (or not controlled) independently.
Client classes are defined by its network addresses (IPv4 or IPv6). Each
client class can define absolute or relative (to wan) bandwith, and also
the use (or not) of spare wan bandwidth when avaiable.

endef

define Package/trafficshaper/conffiles
/etc/config/trafficshaper
endef

define Build/Compile
endef

define Package/trafficshaper/install
$(CP) ./files/* $(1)
endef

$(eval $(call BuildPackage,trafficshaper))
