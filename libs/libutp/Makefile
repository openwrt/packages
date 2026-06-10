include $(TOPDIR)/rules.mk

PKG_NAME:=libutp
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/transmission/libutp
PKG_SOURCE_DATE:=2024-11-16
PKG_SOURCE_VERSION:=490874c44a2ecf914404b0a20e043c9755fff47b
PKG_MIRROR_HASH:=b8489e3770f6479e0a2fce9a472e99a873a69ad0775b7c6c57249e16681c11c0

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libutp
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=The uTorrent Transport Protocol library
  DEPENDS:=+libstdcpp
endef

# MAKE_VARS+=OPT="-I$(PKG_BUILD_DIR)/include/libutp -I$(PKG_BUILD_DIR)/include"

CMAKE_OPTIONS += \
	-DLIBUTP_SHARED:BOOL=YES \
	-DLIBUTP_ENABLE_INSTALL:BOOL=YES \
	-DLIBUTP_ENABLE_WERROR:BOOL=NO \
	-DLIBUTP_BUILD_PROGRAMS:BOOL=NO

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/libutp $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libutp/*.h $(1)/usr/include/libutp
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libutp.so $(1)/usr/lib/
endef

define Package/libutp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libutp.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libutp))
