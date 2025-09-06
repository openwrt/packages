include $(TOPDIR)/rules.mk

PKG_NAME:=gperftools
PKG_VERSION:=2.17.2
PKG_RELEASE:=1

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

define Package/gperftools-headers
  CATEGORY:=Libraries
  SECTION:=libs
  TITLE:=Gperftools Headers
  URL:=https://github.com/gperftools/gperftools
  DEPENDS:= @!(mips||mips64||mipsel||powerpc)
endef

define Package/gperftools-runtime
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Gperftools Runtime
  URL:=https://github.com/gperftools/gperftools
  DEPENDS:= +libunwind +libstdcpp @!(mips||mips64||mipsel||powerpc)
endef

define Package/gperftools-headers/description
  Gperftools is a collection of a high-performance multi-threaded malloc() implementation, plus some pretty nifty performance analysis tools.
  This package contains the headers.
endef

define Package/gperftools-runtime/description
  Gperftools is a collection of a high-performance multi-threaded malloc() implementation, plus some pretty nifty performance analysis tools.
  This package contains the shared objects and bins.
endef

CONFIGURE_ARGS += \
	--enable-frame-pointers \
	--enable-libunwind \
	--disable-deprecated-pprof

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtcmalloc.so* $(1)/usr/lib/
endef

define Package/gperftools-headers/install
	$(INSTALL_DIR) $(1)/usr/include/gperftools
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/gperftools/tcmalloc.h $(1)/usr/include/gperftools
endef

define Package/gperftools-runtime/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtcmalloc.so* $(1)/usr/lib/
endef
$(eval $(call BuildPackage,gperftools-headers))
$(eval $(call BuildPackage,gperftools-runtime))
