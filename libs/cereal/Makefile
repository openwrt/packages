#
# Copyright © 2020 David Woodhouse <dwmw2@infradead.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=cereal
PKG_VERSION:=1.3.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/USCiLab/cereal/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=16a7ad9b31ba5880dac55d62b5d6f243c3ebc8d46a3514149e56b5e7ea81f85f

PKG_MAINTAINER:=David Woodhouse <dwmw2@infradead.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:usc:cereal

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += \
	-DCMAKE_CXX_FLAGS=-latomic \
	-DBUILD_DOC=OFF \
	-DJUST_INSTALL_CEREAL=ON \
	-DSKIP_PORTABILITY_TEST=ON \
	-DSKIP_PERFORMANCE_COMPARISON=ON \
	-DWITH_WERROR=OFF

define Package/cereal
  BUILDONLY:=1
  SECTION:=devel
  CATEGORY:=Development
  SUBMENU:=Libraries
  TITLE:=Cereal is a library of C++ header files for serialization
  URL:=https://github.com/USCilab/cereal
endef


define Package/cereal/description
  Cereal is a library of C++ headers for serialization
endef

$(eval $(call BuildPackage,cereal))
