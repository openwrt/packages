#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libmatroska
PKG_VERSION:=1.6.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Matroska-Org/libmatroska/tar.gz/release-$(PKG_VERSION)?
PKG_HASH:=924e4fc769764fd5ba0f8efcea342a7dc0e6e6aa4c6d7b67c7efab14e75fd54f
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-release-$(PKG_VERSION)

PKG_MAINTAINER:=
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE.LGPL

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=libebml

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libmatroska
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=a C++ libary to parse Matroska files (.mkv and .mka)
  URL:=https://github.com/Matroska-Org/libmatroska
  DEPENDS:=+libstdcpp
  BUILDONLY:=1
endef

define Package/libmatroska/description
  a C++ libary to parse and create Matroska files
endef

CMAKE_OPTIONS += \
	-DDISABLE_PKGCONFIG=OFF \
	-DDISABLE_CMAKE_CONFIG=OFF

TARGET_CFLAGS += -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

$(eval $(call BuildPackage,libmatroska))
