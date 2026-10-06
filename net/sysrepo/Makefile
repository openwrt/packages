#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sysrepo
PKG_VERSION:=5.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/sysrepo/sysrepo/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=e43d59320309f81c14f7f4224661253df767ebcc9a9b269a54b3577c96f406e4

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libsysrepo
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=YANG-based data store library
  URL:=https://www.sysrepo.org/
  DEPENDS:=+libyang $(ATOMIC64_DEPENDS) +librt +libpthread
endef

define Package/sysrepo
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=YANG-based data store daemon and plugin
  URL:=https://www.sysrepo.org/
  DEPENDS:=+libsysrepo
endef

define Package/sysrepoctl
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=sysrepo cli tool
  URL:=https://www.sysrepo.org/
  DEPENDS:=+libsysrepo
endef

define Package/sysrepocfg
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=sysrepo configuration tool
  URL:=https://www.sysrepo.org/
  DEPENDS:=+libsysrepo
endef

define Package/sysrepo/description
Sysrepo is an YANG-based configuration and operational state data store for Unix/Linux applications.
endef


TARGET_LDFLAGS += -Wl,--as-needed

CMAKE_OPTIONS += \
	-DENABLE_TESTS:BOOL=FALSE \
	-DENABLE_EXAMPLES:BOOL=FALSE \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DPRINTED_CONTEXT_ADDRESS=0 \
	-DNOTIFD_SETUP:BOOL=OFF

define Package/libsysrepo/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsysrepo.so* $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/etc/sysrepo/yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-netconf-with-defaults@2011-06-01.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-netconf-notifications@2012-02-06.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-netconf@2013-09-29.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ietf-origin@2018-02-14.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/sysrepo@2025-04-04.yang $(1)/etc/sysrepo/yang/

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/libsysrepo.default $(1)/etc/uci-defaults/95_libsysrepo
endef

define Package/sysrepo/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/sysrepo-plugind $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/sysrepo.init $(1)/etc/init.d/sysrepo
endef

define Package/sysrepoctl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/sysrepoctl $(1)/usr/bin/
endef

define Package/sysrepocfg/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/sysrepocfg $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libsysrepo))
$(eval $(call BuildPackage,sysrepo))
$(eval $(call BuildPackage,sysrepoctl))
$(eval $(call BuildPackage,sysrepocfg))
