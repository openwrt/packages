include $(TOPDIR)/rules.mk

PKG_NAME:=libdht
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/jech/dht
PKG_SOURCE_DATE:=2023-03-18
PKG_SOURCE_VERSION:=0bbb8f4a5bd914b60de5e9fbb51573aa33a1cf18
PKG_MIRROR_HASH:=4a24bd406dd0ac9e69d75f062b45bc0d660f1f8bed9672afc35a7afe4b13acf4

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENCE

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

include $(INCLUDE_DIR)/package.mk

# Upstream ships a plain Makefile that builds only a test binary, so the
# shared object is built here -- and given a soname, since a bare libdht.so
# leaves no way to express an ABI break. jech/dht offers no ABI guarantee of
# its own, so this is a packaged ABI epoch: bump PKG_ABI_VERSION if the
# exported surface changes.
PKG_ABI_VERSION:=0

define Package/libdht
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Kademlia Distributed Hash Table (DHT) library
  DEPENDS:= +USE_GLIBC:libcrypt-compat
  ABI_VERSION:=$(PKG_ABI_VERSION)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/dht $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/dht.h $(1)/usr/include/dht
	$(CP) $(PKG_BUILD_DIR)/libdht.so* $(1)/usr/lib/
endef

define Package/libdht/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libdht.so.$(PKG_ABI_VERSION) $(1)/usr/lib/
endef

define Build/Compile
	$(TARGET_CC) $(FPIC) $(TARGET_CFLAGS) $(TARGET_CPPFLAGS) -Wall \
		-c -o $(PKG_BUILD_DIR)/dht.o $(PKG_BUILD_DIR)/dht.c
	$(TARGET_CC) $(TARGET_LDFLAGS) -shared -Wl,-soname,libdht.so.$(PKG_ABI_VERSION) \
		-o $(PKG_BUILD_DIR)/libdht.so.$(PKG_ABI_VERSION) $(PKG_BUILD_DIR)/dht.o -lcrypt
	ln -sf libdht.so.$(PKG_ABI_VERSION) $(PKG_BUILD_DIR)/libdht.so
endef

$(eval $(call BuildPackage,libdht))
