include $(TOPDIR)/rules.mk

PKG_NAME:=gperftools
PKG_VERSION:=2.17.2
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/gperftools/gperftools/tar.gz/$(PKG_NAME)-$(PKG_VERSION)?
PKG_HASH:=885dbbf1f25a922de0cdc78b0703c3ab93c43850e1d2f7c889e41be7c824c53d
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_FLAGS:=no-mips16
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/gperftools
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Gperftools Runtime
  URL:=https://github.com/gperftools/gperftools
  DEPENDS:=+PACKAGE_libunwind:libunwind +libstdcpp @!(powerpc)
  ABI_VERSION:=4
endef

define Package/gperftools/description
  Gperftools is a collection of a high-performance multi-threaded malloc() implementation, plus some pretty nifty performance analysis tools.
  This package contains the shared libraries.
endef

CONFIGURE_ARGS += \
	--enable-frame-pointers \
	$(if $(CONFIG_PACKAGE_libunwind),--enable-libunwind,--disable-libunwind) \
	--disable-deprecated-pprof

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtcmalloc.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/include/gperftools
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gperftools/*.h $(1)/usr/include/gperftools/
endef

define Package/gperftools/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtcmalloc.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,gperftools))
