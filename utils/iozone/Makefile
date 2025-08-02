include $(TOPDIR)/rules.mk

PKG_NAME:=iozone3
PKG_VERSION:=507
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).tar
PKG_SOURCE_URL:=https://www.iozone.org/src/current/
PKG_HASH:=1e8087ada056f5d8018ee0bc76686d416fc2251ed03038055dbd0af78d1e5ce3

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_$(PKG_VERSION)

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=CUSTOM
PKG_LICENSE_FILES:=License.txt

include $(INCLUDE_DIR)/package.mk

ifeq ($(ARCH),arm)
  IOZONE_TARGET:=linux-arm
else ifeq ($(ARCH),aarch64)
  IOZONE_TARGET:=linux-arm
else ifeq ($(ARCH),powerpc)
  IOZONE_TARGET:=linux-powerpc
else ifeq ($(ARCH),powerpc64)
  IOZONE_TARGET:=linux-powerpc64
else ifeq ($(ARCH),x86_64)
  IOZONE_TARGET:=linux-AMD64
else ifeq ($(ARCH),x86)
  IOZONE_TARGET:=linux
endif

define Package/iozone
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=A filesystem benchmark tool
  URL:=http://iozone.org
  DEPENDS:=@arm||aarch64||powerpc||powerpc64||x86||x86_64
endef

define Package/iozone/description
 IOzone is a filesystem benchmark tool that can measure
 a variety of file operations.
endef

define Build/Compile
	$(MAKE) -j1 -C $(PKG_BUILD_DIR)/src/current $(IOZONE_TARGET) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS) $(FPIC)"
endef

define Package/iozone/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/current/iozone $(1)/usr/bin/
endef

$(eval $(call BuildPackage,iozone))
