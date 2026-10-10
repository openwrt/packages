include $(TOPDIR)/rules.mk

PKG_NAME:=libjwt
PKG_VERSION:=3.6.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/benmcollins/libjwt/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=b483a5f77e548964553f54a0ec5f0c810cc6c0629c5ac5a03610bcced150e7be

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
  ABI_VERSION:=14
endef

define Package/libjwt/description
 JSON Web Tokens are an open, industry standard RFC 7519 method for representing claims securely between two parties.
 libjwt seems to be the most popular implementation written in C.
endef


define Package/libjwt/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjwt.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libjwt))
