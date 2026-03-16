include $(TOPDIR)/rules.mk

PKG_NAME:=ivykis
PKG_VERSION:=0.43.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/libivykis
PKG_HASH:=93e3e9b237695437cd63d4aa48a8d9dfd8b39bc28a192a5770d113c4fe9099ef

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_CONFIG_DEPENDS:=CONFIG_KERNEL_IO_URING

include $(INCLUDE_DIR)/package.mk

define Package/ivykis
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Async I/O library
  URL:=https://libivykis.sourceforge.net/
  DEPENDS:=+KERNEL_IO_URING:liburing
  ABI_VERSION:=0
endef

define Package/ivykis/description
  libivykis is a library for asynchronous I/O readiness notification.
endef

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--with-pic \
	--enable-io-uring=$(if $(CONFIG_KERNEL_IO_URING),yes,no)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/iv*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libivykis.a $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libivykis.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/ivykis.pc $(1)/usr/lib/pkgconfig/
endef

define Package/ivykis/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libivykis.so.$(ABI_VERSION)* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,ivykis))
