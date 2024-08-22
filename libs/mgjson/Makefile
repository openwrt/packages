include $(TOPDIR)/rules.mk

PKG_NAME:=mgjson
PKG_RELEASE:=1

PKG_SOURCE_URL=https://github.com/TheRootED24/mgjson.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2024-08-22

PKG_SOURCE_VERSION:=b0182ca18f1dfabdf9eec188afb58549b738b8be
PKG_MIRROR_HASH:=02c3974ff71f9537f0e48f56b229aa68f2ba53a6201e1e3bec343f1e617c1ef4

PKG_MAINTAINER:=Scott Mercer <TheRootED24@gmail.com>

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/mgjson
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A Stripped down version of The Mongoose C Networking Library. 
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/mgjson
	$(CP) \
		$(PKG_BUILD_DIR)/src/*.h \
		$(1)/usr/include/mgjson/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_BUILD_DIR)/src/libmgjson.so \
		$(1)/usr/lib/
	
endef

define Package/mgjson/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ipkg-install/usr/lib/libmgjson.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,mgjson))
