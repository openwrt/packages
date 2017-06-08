#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_LICENSE:=ASL-2.0
PKG_MAINTAINER:=Mislav Novakovic <mislav.novakovic@sartura.hr>

PKG_NAME:=sysrepo
PKG_VERSION:=0.6.0
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=e4a5705a4c5293ba121048c71899b98243d99edf
PKG_MIRROR_HASH:=aa0fb5d7c947dd428d9f573c84edf6237c8c1a4db92dcd4d7552a68d25277a39
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/sysrepo/sysrepo.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_SOURCE_VERSION)

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

CMAKE_INSTALL:=1

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libsysrepo
  SECTION:=util
  CATEGORY:=Utilities
  URL:=$(PKG_SOURCE_URL)
  TITLE:=YANG-based data store library
  DEPENDS:=+libyang +libprotobuf-c +libev +libavl
endef

define Package/sysrepo
  SECTION:=util
  CATEGORY:=Utilities
  URL:=$(PKG_SOURCE_URL)
  TITLE:=YANG-based data store daemon and plugin
  DEPENDS:=+libsysrepo
endef

define Package/sysrepoctl
  SECTION:=util
  CATEGORY:=Utilities
  URL:=$(PKG_SOURCE_URL)
  TITLE:=sysrepo cli tool
  DEPENDS:=+libsysrepo
endef

define Package/sysrepocfg
  SECTION:=util
  CATEGORY:=Utilities
  URL:=$(PKG_SOURCE_URL)
  TITLE:=sysrepo configuration tool
  DEPENDS:=+libsysrepo
endef

define Package/sysrepo/description
Sysrepo is an YANG-based configuration and operational state data store for Unix/Linux applications.
endef

CMAKE_OPTIONS += \
	-DCMAKE_BUILD_TYPE:STRING=Release \
	-DENABLE_TESTS:BOOL=FALSE \
	-DBUILD_EXAMPLES:BOOL=FALSE \
	-DCMAKE_DISABLE_FIND_PACKAGE_SWIG=TRUE \
	-DGEN_LANGUAGE_BINDINGS:BOOL=FALSE \
	-DREPOSITORY_LOC:PATH=/etc/sysrepo \
	-DCMAKE_INSTALL_PREFIX:PATH=/usr \
	-DENABLE_NACM:BOOL=FALSE \
	-DREQUEST_TIMEOUT=6 \
	-DLONG_REQUEST_TIMEOUT=30 \
	-DCOMMIT_VERIFY_TIMEOUT=20 \
	-DOPER_DATA_PROVIDE_TIMEOUT=4 \
	-DNOTIF_AGE_TIMEOUT=120 \
	-DNOTIF_TIME_WINDOW=20 \
	-DUSE_SR_MEM_MGMT=0

define Package/libsysrepo/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/libsysrepo.so* $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/etc/sysrepo/yang/internal
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/yang/sysrepo-module-dependencies.yang $(1)/etc/sysrepo/yang/internal
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/yang/sysrepo-notification-store.yang $(1)/etc/sysrepo/yang/internal
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/yang/sysrepo-persistent-data.yang $(1)/etc/sysrepo/yang/internal

	$(INSTALL_DIR) $(1)/etc/sysrepo/yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/yang/ietf-netconf-acm@2012-02-22.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/yang/ietf-netconf-notifications.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/yang/nc-notifications.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/yang/notifications.yang $(1)/etc/sysrepo/yang/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/yang/ietf-netconf@2011-06-01.yang $(1)/etc/sysrepo/yang/

	$(INSTALL_DIR) $(1)/etc/sysrepo/data/internal
	$(INSTALL_DIR) $(1)/etc/sysrepo/data/notifications

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/libsysrepo.default $(1)/etc/uci-defaults/95_libsysrepo
endef

define Package/sysrepo/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/sysrepod $(1)/bin/

	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/sysrepo-plugind $(1)/bin/

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/sysrepo.init $(1)/etc/init.d/sysrepo
endef

define Package/sysrepoctl/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/sysrepoctl $(1)/bin/
endef

define Package/sysrepocfg/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/sysrepocfg $(1)/bin/
endef

$(eval $(call BuildPackage,libsysrepo))
$(eval $(call BuildPackage,sysrepo))
$(eval $(call BuildPackage,sysrepoctl))
$(eval $(call BuildPackage,sysrepocfg))
