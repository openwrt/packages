#
# Copyright (C) 2019 Banglang Huang <banglang.huang@foxmail.com>
# Copyright (C) 2019 Rosy Song <rosysong@rosinson.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=log4cplus
PKG_VERSION:=2.0.5
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@SF/$(PKG_NAME)
PKG_HASH:=6046f0867ce4734f298418c7b7db0d35c27403090bb751d98e6e76aa4935f1af

PKG_MAINTAINER:=BangLang Huang <banglang.huang@foxmail.com>, Rosy Song <rosysong@rosinson.com>
PKG_LICENSE:=BSD-2-Clause Apache-2.0
PKG_LICENSE_FILES:=LICENSE

HOST_BUILD_PARALLEL:=1
PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/log4cplus
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A simple to use C++ logging API
  URL:=https://sourceforge.net/p/log4cplus/wiki/Home/
  DEPENDS:=+libstdcpp
endef

define Package/log4cplus/description
  log4cplus is a simple to use C++11 logging API providing thread--safe,
  flexible, and arbitrarily granular control over log management and
  configuration. It is modeled after the Java log4j API.
endef

OPTIONS:= \
	-DLOG4CPLUS_BUILD_LOGGINGSERVER:BOOL=OFF \
	-DLOG4CPLUS_BUILD_TESTING:BOOL=OFF \
	-DUNICODE:BOOL=OFF \
	-DWITH_ICONV:BOOL=OFF

CMAKE_HOST_OPTIONS += $(OPTIONS)
CMAKE_OPTIONS += $(OPTIONS)

TARGET_CFLAGS += -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

define Package/log4cplus/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liblog4cplus*.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,log4cplus))
$(eval $(call HostBuild))
