include $(TOPDIR)/rules.mk

PKG_NAME:=libdht
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/jech/dht
PKG_SOURCE_DATE:=2023-03-18
PKG_SOURCE_VERSION:=0bbb8f4a5bd914b60de5e9fbb51573aa33a1cf18
PKG_MIRROR_HASH:=4a24bd406dd0ac9e69d75f062b45bc0d660f1f8bed9672afc35a7afe4b13acf4

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

include $(INCLUDE_DIR)/package.mk

define Package/libdht
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Kademlia Distributed Hash Table (DHT) library
  DEPENDS:= +USE_GLIBC:libcrypt-compat
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/dht $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/dht.h $(1)/usr/include/dht
	$(CP) $(PKG_BUILD_DIR)/libdht.so $(1)/usr/lib/
endef

define Package/libdht/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libdht.so $(1)/usr/lib/
endef

define Build/Compile
	$(TARGET_CC) $(FPIC) -Wall -c -o $(PKG_BUILD_DIR)/dht.o $(PKG_BUILD_DIR)/dht.c
	$(TARGET_CC) -shared -lcrypt -o $(PKG_BUILD_DIR)/libdht.so $(PKG_BUILD_DIR)/dht.o
endef

$(eval $(call BuildPackage,libdht))
