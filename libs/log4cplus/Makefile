#
# Copyright (C) 2019 Banglang Huang <banglang.huang@foxmail.com>
# Copyright (C) 2019 Rosy Song <rosysong@rosinson.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=log4cplus
PKG_VERSION:=2.0.3
PKG_RELEASE:=2
PKG_MAINTAINER:=BangLang Huang <banglang.huang@foxmail.com>, Rosy Song <rosysong@rosinson.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/log4cplus/log4cplus/releases/download/REL_2_0_3/
PKG_HASH:=c55742c348d09b33219eea00d65b05bdd78ea967761b980b7134855fe24c5f73

PKG_LICENSE_FILES:=LICENSE
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

TARGET_CFLAGS += -flto

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

CMAKE_OPTIONS += \
	-DLOG4CPLUS_BUILD_LOGGINGSERVER:BOOL=OFF \
	-DLOG4CPLUS_BUILD_TESTING:BOOL=OFF \
	-DUNICODE:BOOL=OFF \
	-DWITH_ICONV:BOOL=OFF

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/log4cplus $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liblog4cplus*.so* $(1)/usr/lib
endef

define Package/log4cplus/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liblog4cplus*.so* $(1)/usr/lib
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,log4cplus))
