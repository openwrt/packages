include $(TOPDIR)/rules.mk

PKG_NAME:=googletest
PKG_VERSION:=1.8.1
PKG_MAINTAINER:=Vladimir Inshakov <markoni48@yandex.ru>
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/google/googletest.git
PKG_SOURCE_DATE:=2020-05-14
PKG_SOURCE_VERSION:=011959aafddcd30611003de96cfd8d7a7685c700

CMAKE_INSTALL:=1
CMAKE_OPTIONS:=-DBUILD_SHARED_LIBS=ON

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libgtest
  SECTION:=devel
  CATEGORY:=Development
  SUBMENU:=Libraries
  TITLE:=Google's framework for writing C++ tests
  URL:=https://github.com/google/googletest
  DEPENDS:=+libstdcpp
endef

define Package/libgmock
  SECTION:=devel
  CATEGORY:=Development
  SUBMENU:=Libraries
  TITLE:=Google's framework for writing C++ tests
  URL:=https://github.com/google/googletest
  DEPENDS:=+libstdcpp +libgtest
endef

define Package/libgtest/description
 Google's framework for writing C++ tests on a variety of platforms. Based on
 the xUnit architecture. Supports automatic test discovery, a rich set of
 assertions, user-defined assertions, death tests, fatal and non-fatal failures,
 value- and type-parameterized tests, various options for running the tests.
endef

define Package/libgmock/description
 Inspired by jMock, EasyMock, and Hamcrest, and designed with C++'s
 specifics in mind, it can help you derive better designs of your
 system and write better tests.
endef

define Package/libgtest/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libgtest* $(1)/usr/lib
endef

define Package/libgmock/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libgmock* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libgtest))
$(eval $(call BuildPackage,libgmock))
