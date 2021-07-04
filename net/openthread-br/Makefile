#
#  Copyright (c) 2021, The OpenThread Authors.
#  All rights reserved.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openthread-br
PKG_RELEASE:=1
PKG_VERSION:=0.3.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/openthread/ot-br-posix.git
PKG_SOURCE_DATE:=2021-04-23
PKG_SOURCE_VERSION:=5a3c3221d6ae6b087d0933d98657ba818ae6ff31
PKG_MIRROR_HASH:=1ba73550142d9f41f1528b064e4ef85c9114fc2b0da3fa7fee528e300975bf8a

PKG_MAINTAINER:=OpenThread Maintainers <openthread-maintainers@googlegroups.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../../devel/ninja/ninja-cmake.mk

CMAKE_OPTIONS += \
	-DBUILD_TESTING=OFF \
	-DOTBR_MDNS=OFF \
	-DOT_READLINE=OFF \
	-DOTBR_OPENWRT=ON

define Package/openthread-br
	SECTION:=base
	CATEGORY:=Network
	TITLE:=OpenThread Border Router
	DEPENDS:=+libstdcpp +libjson-c +libubus +libblobmsg-json
endef

define Package/openthread-br/description
    A Thread border router for POSIX-based platforms.
endef

define Package/openthread-br/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/otbr-agent $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ot-ctl $(1)/usr/sbin

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/etc/init.d/otbr-agent $(1)/etc/init.d

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/admin
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/openwrt/controller/thread.lua $(1)/usr/lib/lua/luci/controller/admin

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
	$(CP) $(PKG_BUILD_DIR)/src/openwrt/view/admin_thread $(1)/usr/lib/lua/luci/view

	$(INSTALL_DIR) $(1)/www/luci-static/resources
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/openwrt/handle_error.js $(1)/www/luci-static/resources
endef

$(eval $(call BuildPackage,openthread-br))
