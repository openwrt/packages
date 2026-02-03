include $(TOPDIR)/rules.mk

PKG_NAME:=openal-soft
PKG_VERSION:=1.24.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/kcat/openal-soft/tar.gz/$(PKG_VERSION)?
PKG_HASH:=7e1fecdeb45e7f78722b776c5cf30bd33934b961d7fd2a11e0494e064cc631ce

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=LGPL-2.0-only BSD-3-Clause
PKG_LICENSE_FILES:=BSD-3Clause COPYING LICENSE-pffft

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS +=\
	-DALSOFT_UTILS=OFF \
	-DALSOFT_EXAMPLES=OFF \
	-DALSOFT_INSTALL_EXAMPLES=OFF \
	-DALSOFT_INSTALL_UTILS=OFF

define Package/openal-soft
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=OpenAL Soft
  DEPENDS:=+libatomic +libstdcpp
  URL:=https://openal-soft.org
endef

define Package/openal-soft/description
 OpenAL Soft is an LGPL-licensed, cross-platform, software
 implementation of the OpenAL 3D audio API.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/AL
	$(CP) $(PKG_INSTALL_DIR)/usr/include/AL/* $(1)/usr/include/AL
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libopenal.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/cmake/OpenAL
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cmake/OpenAL/* $(1)/usr/lib/cmake/OpenAL/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/openal.pc $(1)/usr/lib/pkgconfig/
endef

define Package/openal-soft/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libopenal.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/share/openal
	$(CP) $(PKG_INSTALL_DIR)/usr/share/openal/* $(1)/usr/share/openal
endef

$(eval $(call BuildPackage,openal-soft))
