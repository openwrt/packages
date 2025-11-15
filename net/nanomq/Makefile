# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2025 Andrew Yong <me@ndoo.sg>

include $(TOPDIR)/rules.mk

PKG_NAME:=nanomq
PKG_VERSION:=0.24.5
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/nanomq/nanomq.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_MIRROR_HASH:=bd98194ee03032ccd5e1b7c2faf1e8bfff55b76a916550072070ac93e46e6460

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Andrew Yong <me@ndoo.sg>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS+= \
	-DBUILD_CLIENT=OFF

define Package/nanomq
  SECTION:=net
  CATEGORY:=Network
  TITLE:=NanoMQ Broker
  URL:=https://github.com/nanomq/nanomq
  DEPENDS:=+libatomic
endef

define Package/nanomq/description
  An ultra-lightweight and blazing-fast Messaging Broker/Bus for IoT Edge & SDV
endef

define Package/nanomq/conffiles
/etc/nanomq.conf
endef

define Package/nanomq/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nanomq $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/nanomq.init $(1)/etc/init.d/nanomq
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/usr/etc/nanomq.conf $(1)/etc/
endef

$(eval $(call BuildPackage,nanomq))
