include $(TOPDIR)/rules.mk

PKG_NAME:=googletest
PKG_VERSION:=1.17.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/google/googletest/archive/refs/tags/
PKG_SOURCE_URL_FILE:=v$(PKG_VERSION).tar.gz
PKG_HASH:=65fab701d9829d38cb77c14acdc431d2108bfdbf8979e40eb8ae567edf10b27c

CMAKE_INSTALL:=1
PKG_CPE_ID:=cpe:/a:google:google_test

PKG_MAINTAINER:=Jungo Lin <jungolin.tw@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/googletest
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=GoogleTest (gtest)
  URL:=https://github.com/google/googletest
endef

define Package/googletest/description
  GoogleTest (gtest) is a C++ testing framework.
endef

# Option for static/shared
define Package/googletest/config
  config GTEST_STATIC
    bool "Build static library"
    default y
endef

# CMake options
CMAKE_OPTIONS += \
		-DBUILD_GMOCK=ON \
		-DBUILD_GTEST=ON \
		-DINSTALL_GTEST=ON \
		-DBUILD_SHARED_LIBS=$(if $(CONFIG_GTEST_STATIC),OFF,ON)

define Package/googletest/install
	$(INSTALL_DIR) $(1)/usr/lib
ifeq ($(CONFIG_GTEST_STATIC),y)
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libg*.a $(1)/usr/lib/
else
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libg*.so* $(1)/usr/lib/
endif
	$(INSTALL_DIR) $(1)/usr/include/gtest
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gtest/* $(1)/usr/include/gtest/
	$(INSTALL_DIR) $(1)/usr/include/gmock
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gmock/* $(1)/usr/include/gmock/
endef

$(eval $(call BuildPackage,googletest))
$(eval $(call HostBuild))
