include $(TOPDIR)/rules.mk

PKG_NAME:=gflags
PKG_VERSION:=2.2.2
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/gflags/gflags/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=34af2f15cf7367513b352bdcd2493ab14ce43692d2dcd9dfc499492966c64dcf

PKG_MAINTAINER:=Amol Bhave <ambhave@fb.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING.txt

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/cmake.mk

PKG_BUILD_PARALLEL:=1
HOST_BUILD_PARALLEL:=1
CMAKE_OPTIONS:= \
	-DGFLAGS_BUILD_SHARED_LIBS=ON \
	-DGFLAGS_BUILD_STATIC_LIBS=ON
CMAKE_INSTALL:=1

define Package/gflags
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=C++ library that implements commandline flags processing
	DEPENDS:=+libstdcpp +libpthread
	URL:=https://github.com/gflags/gflags
endef

define Package/gflags/description
	The gflags package contains a C++ library that implements commandline flags
	processing. It includes built-in support for standard types such as string and
	the ability to define flags in the source file in which they are used.
endef

define Package/gflags/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgflags.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,gflags))
$(eval $(call HostBuild))
