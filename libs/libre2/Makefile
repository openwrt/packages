include $(TOPDIR)/rules.mk

PKG_NAME:=re2
PKG_VERSION:=2019-07-01
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/google/re2/tar.gz/$(PKG_VERSION)?
PKG_HASH:=de6c3ee49b2cecdfd2936af18d6947db36726590e566b5915db3746784c55745

PKG_MAINTAINER:=Amol Bhave <ambhave@fb.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

HOST_BUILD_PARALLEL:=1
PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/re2
	SECTION:=libs
	CATEGORY:=Libraries
	DEPENDS:=+libstdcpp
	TITLE:=RE2 is a fast, safe, thread-friendly alternative to backtracking regular expression engines like those used in PCRE, Perl, and Python. It is a C++ library.
	URL:=https://github.com/google/re2
endef

define Package/re2/config
	choice
		prompt "Compile RE2 library."
			default RE2_SHARED
			help
				Choose which version to compile.
				-> Shared:
					- Only Shared lib will be compiled.
				-> Static:
					- Only Static lib will be compiled.

		config RE2_SHARED
			bool "Shared"

		config RE2_STATIC
			bool "Static"
	endchoice
endef

define Package/re2/description
	RE2 is a fast, safe, thread-friendly alternative to backtracking regular
	expression engines like those used in PCRE, Perl, and Python.
	It is a C++ library.
endef

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=$(if $(CONFIG_RE2_SHARED),ON,OFF)

define Package/re2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libre2.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,re2))
$(eval $(call HostBuild))
