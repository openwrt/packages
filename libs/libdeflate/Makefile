include $(TOPDIR)/rules.mk

PKG_NAME:=libdeflate
PKG_VERSION:=1.17
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ebiggers/libdeflate/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=fa4615af671513fa2a53dc2e7a89ff502792e2bdfc046869ef35160fcc373763

PKG_LICENSE:=COPYING
PKG_LICENSE_FILES:=MIT

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libdeflate
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=library for fast, whole-buffer DEFLATE-based compression and decompression
  URL:=https://github.com/ebiggers/libdeflate
endef

define Package/libdeflate/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libdeflate.so* $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libdeflate.pc $(1)/usr/lib/pkgconfig/
endef

$(eval $(call BuildPackage,libdeflate))
