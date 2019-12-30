include $(TOPDIR)/rules.mk

PKG_NAME:=libtirpc
PKG_VERSION:=1.2.5
PKG_RELEASE:=1

PKG_SOURCE_URL:=@SF/libtirpc
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=f3b6350c7e9c3cd9c58fc7a5e5f8e6be469cc571bb5eb31eb9790b3e675186ca

PKG_MAINTAINER:=Andy Walsh <andy.walsh44+github@gmail.com>
PKG_LICENSE:=BSD-3-Clause

PKG_FIXUP:=autoreconf
PKG_REMOVE_FILES:=autogen.sh aclocal.m4
PKG_INSTALL:=1

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
