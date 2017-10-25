include $(TOPDIR)/rules.mk

PKG_NAME:=glog
PKG_RELEASE:=1
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/google/glog.git
PKG_SOURCE_VERSION:=v0.3.5
PKG_MIRROR_HASH:=4677fba927e2d9cdcbc518c34c88465260d506d88072ea16217a8171310b9a1c

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_LICENSE_FILE:=COPYING

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
