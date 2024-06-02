include $(TOPDIR)/rules.mk

PKG_NAME:=libdht
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/jech/dht
PKG_SOURCE_DATE:=2022-04-27
PKG_SOURCE_VERSION:=111230894416d400c9a1e038a033586bfeaafc93
PKG_MIRROR_HASH:=05805aaaa2c8a5f1eb5534a2f3a55c7727a1fa15f8e05e7bf6f117aaa91ce65c

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

include $(INCLUDE_DIR)/package.mk

define Package/libdht
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Kademlia Distributed Hash Table (DHT) library
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
