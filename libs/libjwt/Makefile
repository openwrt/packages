include $(TOPDIR)/rules.mk

PKG_NAME:=libjwt
PKG_VERSION:=1.17.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/benmcollins/libjwt/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=568cb5c272622e6ae045708594f1eded64fbfc101112d20de51875fce7653c83

PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

CMAKE_OPTIONS += \
        -DBUILD_SHARED_LIBS=ON
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
