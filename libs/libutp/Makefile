include $(TOPDIR)/rules.mk

PKG_NAME:=libutp
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/transmission/libutp
PKG_SOURCE_DATE:=2023-02-14
PKG_SOURCE_VERSION:=c95738b1a6644b919e5b64d3ea9736cfc5894e0b
PKG_MIRROR_HASH:=abc2013d44bc30e4e12f89334f3f196243178699eeefbfc52744652889a150e6

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
	-DLIBUTP_ENABLE_WERROR:BOOL=YES \
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
