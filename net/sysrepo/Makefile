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
PKG_VERSION:=0.7.7
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/sysrepo/sysrepo/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=2bf8cb4d810d19231eba1e549f58f3a0ce068d170a5e7b212b927396098560e4

CMAKE_INSTALL:=1

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
ifeq ($(CONFIG_SYSREPO_PYTHON),y)
$(call include_mk, python-package.mk)
endif

define Package/libsysrepo/config
	source "$(SOURCE)/Config_libsysrepo.in"
endef

PKG_BUILD_DEPENDS:=SYSREPO_BINDINGS:swig/host

define Package/libsysrepo
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=$(PKG_SOURCE_URL)
  TITLE:=YANG-based data store library
  DEPENDS:=+libyang +libprotobuf-c +libev +libredblack +librt +libpthread +SYSREPO_BINDINGS:libstdcpp +SYSREPO_PYTHON:python-base +SYSREPO_LUA:lua
  MENU:=1
endef

define Package/sysrepo
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=$(PKG_SOURCE_URL)
  TITLE:=YANG-based data store daemon and plugin
  DEPENDS:=+libsysrepo
endef

define Package/sysrepoctl
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=$(PKG_SOURCE_URL)
  TITLE:=sysrepo cli tool
  DEPENDS:=+libsysrepo
endef

define Package/sysrepocfg
  SECTION:=utils
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
	-DUSE_AVL_LIB:BOOL=FALSE \
	-DENABLE_TESTS:BOOL=FALSE \
	-DBUILD_EXAMPLES:BOOL=FALSE \
	-DCMAKE_DISABLE_FIND_PACKAGE_SWIG=TRUE \
	-DGEN_LANGUAGE_BINDINGS:BOOL=FALSE \
	-DGEN_PYTHON_BINDINGS=0 \
	-DGEN_LUA_BINDINGS=0 \
	-DREPOSITORY_LOC:PATH=/etc/sysrepo \
	-DCMAKE_INSTALL_PREFIX:PATH=/usr \
	-DENABLE_NACM:BOOL=FALSE \
	-DREQUEST_TIMEOUT=6 \
	-DLONG_REQUEST_TIMEOUT=30 \
	-DCOMMIT_VERIFY_TIMEOUT=20 \
	-DOPER_DATA_PROVIDE_TIMEOUT=4 \
	-DNOTIF_AGE_TIMEOUT=120 \
	-DNOTIF_TIME_WINDOW=20 \
	-DUSE_SR_MEM_MGMT=0 \
	-DFILE_FORMAT_EXT:STRING=xml

ifeq ($(CONFIG_SYSREPO_LUA),y)
CMAKE_OPTIONS += \
	-DGEN_LUA_BINDINGS:BOOL=TRUE \
	-DGEN_LUA_VERSION=5.1
endif

ifeq ($(CONFIG_SYSREPO_PYTHON),y)
CMAKE_OPTIONS += \
	-DGEN_PYTHON_BINDINGS:BOOL=TRUE \
	-DGEN_PYTHON_VERSION=2
endif

ifeq ($(CONFIG_SYSREPO_BINDINGS),y)
CMAKE_OPTIONS += \
	-DCMAKE_DISABLE_FIND_PACKAGE_SWIG=FALSE \
	-DGEN_LANGUAGE_BINDINGS:BOOL=TRUE \
	-DSWIG_DIR=$(STAGING_DIR_HOSTPKG)/share/swig \
	-DSWIG_EXECUTABLE=$(STAGING_DIR_HOSTPKG)/bin/swig \
	-DCALL_TARGET_BINS_DIRECTLY=OFF
endif

define Package/libsysrepo/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/libsysrepo.so* $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/etc/sysrepo/yang/internal
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/yang/sysrepo-module-dependencies.yang $(1)/etc/sysrepo/yang/internal
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/yang/sysrepo-notification-store.yang $(1)/etc/sysrepo/yang/internal
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/yang/sysrepo-persistent-data.yang $(1)/etc/sysrepo/yang/internal

	$(INSTALL_DIR) $(1)/etc/sysrepo/yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/yang/ietf-netconf-acm@2018-02-14.yang $(1)/etc/sysrepo/yang/ietf-netconf-acm@2018-02-14.yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/yang/ietf-netconf-notifications.yang $(1)/etc/sysrepo/yang/ietf-netconf-notifications@2012-02-06.yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/yang/nc-notifications.yang $(1)/etc/sysrepo/yang/nc-notifications@2008-07-14.yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/yang/notifications.yang $(1)/etc/sysrepo/yang/notifications@2008-07-14.yang
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/yang/ietf-netconf@2011-06-01.yang $(1)/etc/sysrepo/yang/ietf-netconf@2011-06-01.yang

	$(INSTALL_DIR) $(1)/etc/sysrepo/data/internal
	$(INSTALL_DIR) $(1)/etc/sysrepo/data/notifications

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/libsysrepo.default $(1)/etc/uci-defaults/95_libsysrepo

ifeq ($(CONFIG_SYSREPO_PYTHON),y)
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/swig/libSysrepo-cpp.so* $(1)/usr/lib
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/swig/python2/libsysrepoPython2.py $(1)$(PYTHON_PKG_DIR)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/swig/python2/_libsysrepoPython2.so $(1)$(PYTHON_PKG_DIR)
endif

ifeq ($(CONFIG_SYSREPO_LUA),y)
	$(INSTALL_DIR) $(1)/usr/lib/lua/
	$(CP) $(PKG_BUILD_DIR)/swig/lua/libSysrepo_Lua.so* $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/swig/lua/libsysrepoLua.so $(1)/usr/lib/lua/libsysrepoLua.so
endif
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

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libsysrepo.pc $(1)/usr/lib/pkgconfig/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/libsysrepo.so* $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/inc/* $(1)/usr/include/
endef

$(eval $(call BuildPackage,libsysrepo))
$(eval $(call BuildPackage,sysrepo))
$(eval $(call BuildPackage,sysrepoctl))
$(eval $(call BuildPackage,sysrepocfg))
