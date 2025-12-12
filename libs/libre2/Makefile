include $(TOPDIR)/rules.mk

PKG_NAME:=re2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/google/re2
PKG_SOURCE_DATE:=2023-02-01
PKG_SOURCE_VERSION:=b025c6a3ae05995660e3b882eb3277f4399ced1a
PKG_MIRROR_HASH:=b473f4fd10d9f0afd65d409cf11dd1fd7b4010cfa4e07cfc99d33e382390baef

PKG_MAINTAINER:=
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/re2
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libstdcpp
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
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libre2.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,re2))
