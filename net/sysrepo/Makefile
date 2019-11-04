#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sysrepo
PKG_VERSION:=0.7.8
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/sysrepo/sysrepo/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=d3066c1776a6727b96bbb3517eb646d0bb6037e8e1addcbe873cae590493843e

PKG_MAINTAINER:=Mislav Novakovic <mislav.novakovic@sartura.hr>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=SYSREPO_BINDINGS:swig/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
ifeq ($(CONFIG_SYSREPO_PYTHON),y)
$(call include_mk, python3-package.mk)
endif

define Package/libsysrepo/config
	source "$(SOURCE)/Config_libsysrepo.in"
endef

define Package/libsysrepo
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=YANG-based data store library
  URL:=https://www.sysrepo.org/
  DEPENDS:=+libyang +libprotobuf-c +libev +libredblack +librt +libpthread +SYSREPO_BINDINGS:libstdcpp +SYSREPO_PYTHON:python3-base +SYSREPO_LUA:lua
  MENU:=1
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

CMAKE_OPTIONS += \
	-DUSE_AVL_LIB:BOOL=FALSE \
	-DENABLE_TESTS:BOOL=FALSE \
	-DBUILD_EXAMPLES:BOOL=FALSE \
	-DCMAKE_DISABLE_FIND_PACKAGE_SWIG=TRUE \
	-DGEN_LANGUAGE_BINDINGS:BOOL=FALSE \
	-DGEN_PYTHON_BINDINGS=0 \
	-DGEN_LUA_BINDINGS=0 \
	-DREPOSITORY_LOC:PATH=/etc/sysrepo \
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
	-DGEN_PYTHON_VERSION=3 \
	-DGEN_PYTHON3_TESTS:BOOL=FALSE
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
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/swig/python3/libsysrepoPython3.py $(1)$(PYTHON_PKG_DIR)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/swig/python3/_libsysrepoPython3.so $(1)$(PYTHON_PKG_DIR)
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

$(eval $(call BuildPackage,libsysrepo))
$(eval $(call BuildPackage,sysrepo))
$(eval $(call BuildPackage,sysrepoctl))
$(eval $(call BuildPackage,sysrepocfg))
