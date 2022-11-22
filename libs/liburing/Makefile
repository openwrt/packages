include $(TOPDIR)/rules.mk

PKG_NAME:=liburing
PKG_VERSION:=2.3
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://git.kernel.dk/cgit/liburing/snapshot
PKG_HASH:=a65a6adbe80425c1c4d0740532ba42c3d4fd9dadd17a0e0bfd31c29e1c14dba8

PKG_MAINTAINER:=Christian Lachner <gladiac@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/liburing
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=io_uring library
  URL:=https://git.kernel.dk/cgit/liburing
  DEPENDS:=@KERNEL_IO_URING
endef

define Package/liburing/description
  liburing provides helpers to setup and teardown io_uring instances,
  and also a simplified interface for applications that don't need
  (or want) to deal with the full kernel side implementation.
  For more info on io_uring, please see: https://kernel.dk/io_uring.pdf
endef

CONFIGURE_ARGS:=--prefix=$(CONFIGURE_PREFIX) --cc=${TARGET_CC}

define Build/Compile
	$(MAKE) $(PKG_BUILD_DIR) \
		DSTROOT="$(PKG_INSTALL_DIR)"
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.{so*,a} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/liburing.pc $(1)/usr/lib/pkgconfig/
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/liburing.pc
	$(SED) 's,/usr/lib,$$$${prefix}/lib,g' $(1)/usr/lib/pkgconfig/liburing.pc
endef

define Package/liburing/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liburing.so $(PKG_INSTALL_DIR)/usr/lib/liburing.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,liburing))
