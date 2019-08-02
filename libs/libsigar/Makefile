include $(TOPDIR)/rules.mk

PKG_NAME:=libsigar
PKG_SOURCE_DATE:=2017-02-21
PKG_SOURCE_VERSION:=a6c61edf8c64e013411e8c9d753165cd03102c6e
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/boundary/sigar
PKG_MIRROR_HASH:=5f017e10ab1d929c9dfb2937fef16a45962b60958cd1569573d18f00fcea290f

PKG_MAINTAINER:=Amol Bhave <ambhave@fb.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILE:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

define Package/libsigar
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=System Information Gatherer And Reporter
	URL:=https://github.com/boundary/sigar
	DEPENDS:=+libtirpc
endef

define Package/libsigar/description
	System Information Gatherer And Reporter
endef

define Package/libsigar/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsigar.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libsigar))
