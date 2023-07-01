include $(TOPDIR)/rules.mk

PKG_NAME:=re2
PKG_VERSION:=2023-02-01
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/google/re2/tar.gz/$(PKG_VERSION)?
PKG_HASH:=cbce8b7803e856827201a132862e41af386e7afd9cc6d9a9bc7a4fa4d8ddbdde

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

define Package/re2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libre2.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,re2))
