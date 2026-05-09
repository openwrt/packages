include $(TOPDIR)/rules.mk

PKG_NAME:=gcem
PKG_RELEASE:=1

# gcem upstream tags only sporadically; pin to the commit that fluidsynth
# 2.5.x's FindGCEM.cmake / submodule references. Update in lockstep with
# the consumer's expected revision.
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/kthohr/gcem.git
PKG_SOURCE_DATE:=2024-04-28
PKG_SOURCE_VERSION:=012ae73c6d0a2cb09ffe86475f5c6fba3926e200
PKG_MIRROR_HASH:=70df878c9d85281c6816c231cbb320a9eccb4fb73ef32612cf8948b17716fc49

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# upstream CMakeLists.txt declares cmake_minimum_required(VERSION 3.1),
# which trips modern CMake's deprecated-policy guard.
CMAKE_OPTIONS += \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5

define Package/gcem
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=GCE-Math header-only constexpr math library
  URL:=https://github.com/kthohr/gcem
  BUILDONLY:=1
endef

define Package/gcem/description
GCE-Math (Generalized Constant Expression Math) is a templated C++
library enabling compile-time computation of mathematical functions.
Header-only; consumed at build time only.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gcem.hpp $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gcem_incl $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/cmake/gcem
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cmake/gcem/* $(1)/usr/lib/cmake/gcem/
endef

define Package/gcem/install
	:
endef

$(eval $(call BuildPackage,gcem))
