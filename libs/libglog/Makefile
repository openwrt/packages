include $(TOPDIR)/rules.mk

PKG_NAME:=glog
PKG_VERSION:=0.3.5
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/google/glog/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=7580e408a2c0b5a89ca214739978ce6ff480b5e7d8d7698a2aa92fadc484d1e0

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILE:=COPYING

PKG_FIXUP:=autoreconf

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/glog
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=C++ implementation of the Google logging module
  DEPENDS:= +libstdcpp +libpthread
  URL:=https://github.com/google/glog
  MAINTAINER:=Amir Sabbaghi <amir@pichak.co>
endef

define Package/glog/description
  This repository contains a C++ implementation of the Google logging
  module.  Documentation for the implementation is in doc/.
endef

CONFIGURE_VARS+=ac_cv_have_libunwind_h=0

TARGET_CXXFLAGS+=-std=c++11
TARGET_LDFLAGS+=-lpthread

define Build/Configure
	$(call Build/Configure/Default,)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/glog
	$(CP) $(PKG_INSTALL_DIR)/usr/include/glog/*.h $(1)/usr/include/glog
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libglog.{a,so*} $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libglog.pc $(1)/usr/lib/pkgconfig/
endef

define Package/glog/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libglog.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,glog))
