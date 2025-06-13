# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=abseil-cpp
PKG_VERSION:=20240722.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/abseil/abseil-cpp/releases/download/$(PKG_VERSION)
PKG_HASH:=f50e5ac311a81382da7fa75b97310e4b9006474f9560ac46f54a9967f07d4ae3

PKG_MAINTAINER:=Austin Lane <vidplace7@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/abseil-cpp
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Collection of C++ code designed to augment the C++ standard library
  URL:=https://github.com/abseil/abseil-cpp
  DEPENDS:=+libpthread +libstdcpp
endef

define Package/abseil-cpp/description
Abseil is an open-source collection of C++ code (compliant to C++14) designed to augment the C++ standard library.
endef

CMAKE_INSTALL:=1

CMAKE_HOST_OPTIONS += \
	-DABSL_PROPAGATE_CXX_STD=ON \
	-DABSL_ENABLE_INSTALL=ON \
	-DABSL_USE_GOOGLETEST_HEAD=OFF

CMAKE_OPTIONS += \
	-DABSL_PROPAGATE_CXX_STD=ON \
	-DABSL_ENABLE_INSTALL=ON \
	-DABSL_USE_GOOGLETEST_HEAD=OFF

TARGET_CFLAGS += $(FPIC)

define Package/abseil-cpp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/*.a $(1)/usr/lib/
endef

define Build/InstallDev
	$(call Build/InstallDev/cmake,$(1))
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/absl_*.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/absl_*.pc
endef

$(eval $(call BuildPackage,abseil-cpp))
$(eval $(call HostBuild))
