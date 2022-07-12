include $(TOPDIR)/rules.mk

PKG_NAME:=td
PKG_VERSION:=1.8.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/tdlib/td/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=30d560205fe82fb811cd57a8fcbc7ac853a5b6195e9cb9e6ff142f5e2d8be217

PKG_MAINTAINER:=Toni Uhlig <matzeton@googlemail.com>
PKG_LICENSE:=BSL-1.0
PKG_LICENSE_FILES:=LICENSE_1_0.txt

PKG_BUILD_DEPENDS:=gperf/host td/host
PKG_BUILD_PARALLEL:=1
CMAKE_BINARY_SUBDIR:=openwrt-build
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/cmake.mk

EXTRA_CFLAGS += -Wno-psabi

define Package/td
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Telegram Database library
  DEPENDS:=+zlib +libopenssl +libstdcpp
  URL:=https://github.com/tdlib/td
endef

define Package/td/description
 Cross-platform library for building Telegram clients.
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	$(INSTALL_DIR) \
		$(PKG_BUILD_DIR)/td/generate/auto \
		$(PKG_BUILD_DIR)/tdutils/generate
	$(CP) \
		$(STAGING_DIR_HOSTPKG)/include/td/generate/auto/td \
		$(PKG_BUILD_DIR)/td/generate/auto/td
	$(CP) \
		$(STAGING_DIR_HOSTPKG)/include/tdutils/generate/auto \
		$(PKG_BUILD_DIR)/tdutils/generate/auto
endef

define Host/Compile
	$(NINJA) -C $(HOST_BUILD_DIR)/$(CMAKE_BINARY_SUBDIR) prepare_cross_compiling
endef

define Host/Install
	$(INSTALL_DIR) \
		$(STAGING_DIR_HOSTPKG)/include/td/generate/auto \
		$(STAGING_DIR_HOSTPKG)/include/tdutils/generate
	$(CP) \
		$(HOST_BUILD_DIR)/td/generate/auto/td \
		$(STAGING_DIR_HOSTPKG)/include/td/generate/auto/td
	$(CP) \
		$(HOST_BUILD_DIR)/tdutils/generate/auto \
		$(STAGING_DIR_HOSTPKG)/include/tdutils/generate/auto
endef

define Package/td/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtdjson.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,td))
$(eval $(call HostBuild))
