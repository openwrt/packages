include $(TOPDIR)/rules.mk

PKG_NAME:=libb64
PKG_VERSION:=2.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/libb64/libb64/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=28c43c47674409fc50e7145d4c2d26dc1f3d200889c41205e7812c2b67f26382

PKG_LICENSE:=Public-Domain
PKG_LICENSE_FILES:=LICENSE.md

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

include $(INCLUDE_DIR)/package.mk

MAKE_FLAGS+=all_src

define Package/libb64
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Base64 Encoding/Decoding Routines
  URL:=https://github.com/libb64/libb64
  BUILDONLY:=1
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/b64 $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/include/b64/*.h $(1)/usr/include/b64
	$(CP) $(PKG_BUILD_DIR)/src/*.a $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libb64))
