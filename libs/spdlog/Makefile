#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=spdlog
PKG_VERSION:=1.7.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/gabime/spdlog/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=f0114a4d3c88be9e696762f37a7c379619443ce9d668546c61b21d41affe5b62

PKG_MAINTAINER:=
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/spdlog
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=spdlog
  URL:=https://github.com/gabime/spdlog
  DEPENDS:=+libfmt
  BUILDONLY:=1
endef

define Package/spdlog/description
  Very fast, header-only/compiled, C++ logging library.
endef

CMAKE_OPTIONS += \
	-DSPDLOG_BUILD_SHARED=OFF \
	-DSPDLOG_BUILD_EXAMPLE=OFF \
	-DSPDLOG_BUILD_EXAMPLE_HO=OFF \
	-DSPDLOG_BUILD_TESTS=OFF \
	-DSPDLOG_BUILD_TESTS_HO=OFF \
	-DSPDLOG_BUILD_BENCH=OFF \
	-DSPDLOG_SANITIZE_ADDRESS=OFF \
	-DSPDLOG_INSTALL=ON \
	-DSPDLOG_FMT_EXTERNAL=ON \
	-DSPDLOG_FMT_EXTERNAL_HO=OFF \
	-DSPDLOG_NO_EXCEPTIONS=OFF

TARGET_CXXFLAGS += -flto

$(eval $(call BuildPackage,spdlog))
