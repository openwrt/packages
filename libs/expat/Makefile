#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=expat
PKG_VERSION:=2.2.10
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-RENAMED-VULNERABLE-PLEASE-USE-2.4.1-INSTEAD.tar.xz
PKG_SOURCE_URL:=@SF/expat
PKG_HASH:=5dfe538f8b5b63f03e98edac520d7d9a6a4d22e482e5c96d4d06fcc5485c25f2

PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:libexpat:expat

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libexpat
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=An XML parsing library
  URL:=https://libexpat.github.io/
endef

define Package/libexpat/description
 A fast, non-validating, stream-oriented XML parsing library.
endef

OPTIONS += \
	-DDOCBOOK_TO_MAN=OFF \
	-DEXPAT_BUILD_TOOLS=OFF \
	-DEXPAT_BUILD_EXAMPLES=OFF \
	-DEXPAT_BUILD_TESTS=OFF \
	-DEXPAT_BUILD_DOCS=OFF \
	-DEXPAT_WITH_LIBBSD=OFF \
	-DEXPAT_ENABLE_INSTALL=ON \
	-DEXPAT_DTD=OFF \
	-DEXPAT_NS=OFF \
	-DEXPAT_DEV_URANDOM=OFF

CMAKE_OPTIONS += $(OPTIONS)
CMAKE_HOST_OPTIONS += $(OPTIONS)

define Package/libexpat/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libexpat.so.* $(1)/usr/lib/
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,libexpat))
