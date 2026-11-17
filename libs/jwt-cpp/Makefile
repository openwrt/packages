#
# Copyright © 2025 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=jwt-cpp
PKG_VERSION:=0.7.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Thalhammer/jwt-cpp/releases/download/v$(PKG_VERSION)/
PKG_HASH:=d45894f57437ce45233cfe0e07383c4e1f32f969edfd8df8347e177b13bf74e5

PKG_MAINTAINER:=David Woodhouse <dwmw2@infradead.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

# To build the examples and tests.
PKG_BUILD_DEPENDS:=openssl nlohmannjson

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# The tarball doesn't include the top-level jwt-cpp-v$(PKG_VERSION)/ directory
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

# We *should* be able to build the examples and tests, but cmake insists on
# finding it using its own nonsense instead of pkg-config, so it isn't found.
CMAKE_OPTIONS += \
	-DJWT_EXTERNAL_NLOHMANN_JSON=yes \
	-DJWT_BUILD_TESTS=no \
	-DJWT_BUILD_EXAMPLES=no

define Package/jwt-cpp
  BUILDONLY:=1
  SECTION:=devel
  CATEGORY:=Development
  SUBMENU:=Libraries
  TITLE:=Header-only C++ library for JSON Web Tokens
  URL:=https://github.com/Thalhammer/jwt-cpp
endef

define Package/jwt-cpp/description
  jwt-cpp is a header only library for creating and validating JSON Web Tokens in C++11
endef

$(eval $(call BuildPackage,jwt-cpp))
