include $(TOPDIR)/rules.mk

PKG_NAME:=nghttp3
PKG_VERSION:=1.3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/ngtcp2/nghttp3/releases/download/v$(PKG_VERSION)/
PKG_HASH:=450525981d302f23832b18edd1a62cf58019392ca6402408d0eb1a7f3fd92ecf

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Aleksey Vasilenko <aleksey.vasilenko@gmail.com>

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libnghttp3
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=HTTP/3 library written in C
  URL:=https://nghttp2.org/nghttp3
endef

define Package/libnghttp3/description
nghttp3 is a thin HTTP/3 layer over an underlying QUIC stack.
endef

CMAKE_OPTIONS += -DENABLE_LIB_ONLY=ON

define Build/InstallDev
	$(call Build/InstallDev/cmake,$(1))
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/libnghttp3.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/libnghttp3.pc
endef

define Package/libnghttp3/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libnghttp3.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libnghttp3))
