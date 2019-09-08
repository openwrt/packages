include $(TOPDIR)/rules.mk

PKG_NAME:=libmstch
PKG_VERSION:=1.0.2
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/no1msd/mstch/tar.gz/$(PKG_VERSION)?
PKG_HASH:=811ed61400d4e9d4f9ae0f7679a2ffd590f0b3c06b16f2798e1f89ab917cba6c
PKG_BUILD_DIR:=$(BUILD_DIR)/mstch-$(PKG_VERSION)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/mstch-$(PKG_VERSION)

PKG_MAINTAINER:=Amol Bhave <ambhave@fb.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

HOST_BUILD_DEPENDS:=boost/host
PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libmstch
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=Complete implementation of {{mustache}} templates using modern C++
	DEPENDS:=+boost +boost-container
	URL:=https://github.com/no1msd/mstch
endef

define Package/libmstch/description
	mstch is a complete implementation of {{mustache}} templates using modern C++
endef

CMAKE_OPTIONS += \
	-DCMAKE_POSITION_INDEPENDENT_CODE=TRUE

$(eval $(call BuildPackage,libmstch))
$(eval $(call HostBuild))
