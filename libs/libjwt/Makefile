include $(TOPDIR)/rules.mk

PKG_NAME:=libjwt
PKG_VERSION:=3.3.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/benmcollins/libjwt/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=d1b16df8e7484d1856c21f770c6317cee3881c435a563160be76cf29d3142c8c

PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON \
	-DWITH_GNUTLS=OFF \
	-DWITH_MBEDTLS=OFF \
	-DWITH_TESTS=OFF
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libjwt
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libjwt
  URL:=https://github.com/benmcollins/libjwt
  DEPENDS:=+libopenssl +jansson
  ABI_VERSION:=0
endef

define Package/libjwt/description
 JSON Web Tokens are an open, industry standard RFC 7519 method for representing claims securely between two parties.
 libjwt seems to be the most popular implementation written in C.
endef


define Package/libjwt/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjwt.so* $(1)/usr/lib/
	$(LN) libjwt.so.0 $(1)/usr/lib/libjwt.so
endef

$(eval $(call BuildPackage,libjwt))
