#
# Copyright (C) 2018-2019 Luiz Angelo Daros de Luca
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=switchdev-poller
PKG_VERSION:=1.0.1
PKG_RELEASE:=1
PKG_MAINTAINER:=Luiz Angelo Daros de Luca <luizluca@gmail.com>
PKG_LICENSE:=GPLv2

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
include $(INCLUDE_DIR)/package.mk

define Package/switchdev-poller
   SECTION:=net
   CATEGORY:=Network
   DEPENDS:=+swconfig
   TITLE:=Poll switchdev port to bring CPU ports up/down
   PKGARCH:=all
endef

define Package/switchdev-poller/description
This service monitors switchdev ports and brings down CPU ports when
all related non-CPU vlan ports are also down. Otherwise, it brings
the port up.

endef

define Build/Compile
endef

define Package/switchdev-poller/install
	$(CP) ./files/* $(1)
endef

$(eval $(call BuildPackage,switchdev-poller))
