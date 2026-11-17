include $(TOPDIR)/rules.mk

PKG_NAME:=re2
PKG_VERSION:=2025.11.05
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/google/re2/archive/refs/tags/
PKG_SOURCE_URL_FILE:=2025-11-05.tar.gz
PKG_HASH:=87f6029d2f6de8aa023654240a03ada90e876ce9a4676e258dd01ea4c26ffd67
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-2025-11-05

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/re2
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libstdcpp +abseil-cpp
  TITLE:=RE2 - C++ regular expression library
  URL:=https://github.com/google/re2
  ABI_VERSION:=10
endef

define Package/re2/description
  RE2 is a fast, safe, thread-friendly alternative to backtracking regular
  expression engines like those used in PCRE, Perl, and Python.
  It is a C++ library.
endef

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON

TARGET_LDFLAGS += \
	-Wl,--as-needed,--gc-sections

define Build/InstallDev
	$(call Build/InstallDev/cmake,$(1))
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/re2.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/re2.pc
endef

define Package/re2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libre2.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,re2))
