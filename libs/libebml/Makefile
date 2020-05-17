#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libebml
PKG_VERSION:=1.3.10
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Matroska-Org/libebml/tar.gz/release-$(PKG_VERSION)?
PKG_HASH:=2562bb9bc3248e956a6ed1148eafe4d7d68759257133083c212d14faa8709d1e
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-release-$(PKG_VERSION)

PKG_MAINTAINER:=
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE.LGPL

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libebml
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=a C++ libary to parse EBML files
  URL:=https://github.com/Matroska-Org/libebml
  DEPENDS:=+libstdcpp
  BUILDONLY:=1
endef

define Package/libebml/description
  a C++ libary to parse EBML files
  Specifications may be rendered at http://matroska-org.github.io/libebml/
endef

CMAKE_OPTIONS += \
	-DDISABLE_PKGCONFIG=OFF \
	-DDISABLE_CMAKE_CONFIG=OFF \
	-DENABLE_WIN32_IO=OFF

TARGET_CFLAGS += -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

$(eval $(call BuildPackage,libebml))
