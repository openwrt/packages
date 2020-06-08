#
# Copyright © 2020 David Woodhouse <dwmw2@infradead.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=cereal
PKG_VERSION:=1.3.0
PKG_RELEASE:=1

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/USCiLab/cereal/archive/
PKG_HASH:=329ea3e3130b026c03a4acc50e168e7daff4e6e661bc6a7dfec0d77b570851d5

PKG_MAINTAINER:=David Woodhouse <dwmw2@infradead.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1

CMAKE_OPTIONS += -DCMAKE_CXX_FLAGS=-latomic -DWITH_WERROR=OFF -DSKIP_PORTABILITY_TEST=ON -DSKIP_PERFORMANCE_COMPARISON=ON

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk


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
