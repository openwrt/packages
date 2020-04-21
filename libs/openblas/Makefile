include $(TOPDIR)/rules.mk

PKG_NAME:=OpenBLAS
PKG_SOURCE_VERSION:=fa42588e1ff540b85f481edf05965049b51347d5
PKG_VERSION:=0.3.9-$(PKG_SOURCE_VERSION)
PKG_RELEASE:=1
#PKG_SOURCE:=v$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=https://github.com/xianyi/OpenBLAS/archive/
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2020-04-21
PKG_SOURCE_URL:=https://github.com/xianyi/OpenBLAS.git
#PKG_HASH:=28cc19a6acbf636f5aab5f10b9a0dfe1
PKG_BUILD_DIR:=$(BUILD_DIR)/OpenBLAS-$(PKG_VERSION)
include $(INCLUDE_DIR)/package.mk


MAKE_VARS+= \
			HOSTCC="gcc"

define Package/openblas
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=An optimized BLAS library
  URL:=https://www.openblas.net/
endef

define Package/bridge/description
  OpenBLAS is an optimized BLAS library based on GotoBLAS2 1.13 BSD version
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig/
endef

define Package/OpenBLAS/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libopenblas*.so.$(PKG_VERSION) $(1)/usr/lib/
	$(LN) /usr/lib/libopenblas.so.$(PKG_VERSION) $(1)/usr/lib/libopenblas.so
	$(LN) /usr/lib/libopenblas.so.$(PKG_VERSION) $(1)/usr/lib/libopenblas.so.$(PKG_ABI_VERSION)
endef
$(eval $(call BuildPackage,openblas))
