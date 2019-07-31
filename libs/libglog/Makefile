include $(TOPDIR)/rules.mk

PKG_NAME:=glog
PKG_VERSION:=0.4.0
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/google/glog/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=f28359aeba12f30d73d9e4711ef356dc842886968112162bc73002645139c39c

PKG_MAINTAINER:=Amir Sabbaghi <asaba90@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/glog
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=C++ implementation of the Google logging module
  DEPENDS:=+libstdcpp +libpthread +gflags
  URL:=https://github.com/google/glog
endef

define Package/glog/description
  This repository contains a C++ implementation of the Google logging
  module.  Documentation for the implementation is in doc/.
endef

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON \
	-DBUILD_TESTING=OFF \
	-DUNWIND_LIBRARY=OFF

TARGET_CFLAGS += -ffunction-sections -fdata-sections -flto
TARGET_CFLAGS += -Wl,--gc-sections

define Package/glog/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libglog.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,glog))
