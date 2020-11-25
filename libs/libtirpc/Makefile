include $(TOPDIR)/rules.mk

PKG_NAME:=libtirpc
PKG_VERSION:=1.2.6
PKG_RELEASE:=2

PKG_SOURCE_URL:=@SF/libtirpc
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=4278e9a5181d5af9cd7885322fdecebc444f9a3da87c526e7d47f7a12a37d1cc

PKG_MAINTAINER:=Andy Walsh <andy.walsh44+github@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/libtirpc
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library TI RPC for RPC bindings
  URL:=http://libtirpc.sourceforge.net/
  DEPENDS:=+libpthread
endef

CONFIGURE_ARGS += --disable-gssapi
HOST_CONFIGURE_ARGS += --disable-gssapi

ifeq ($(HOST_OS),Darwin)
HOST_CONFIGURE_ARGS += --disable-symvers
endif

TARGET_CFLAGS += -DGQ
HOST_CFLAGS += -DGQ

define Package/libtirpc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtirpc.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/netconfig $(1)/etc/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtirpc.{a,so*} $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include
	$(SED) 's,/usr,${STAGING_DIR}/usr,g' $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libtirpc.pc
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libtirpc.pc $(1)/usr/lib/pkgconfig/libtirpc.pc
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,libtirpc))
