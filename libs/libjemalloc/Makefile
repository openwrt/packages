include $(TOPDIR)/rules.mk

PKG_NAME:=jemalloc
PKG_VERSION:=5.3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/jemalloc/jemalloc/archive/refs/tags/
PKG_SOURCE_URL_FILE:=$(PKG_VERSION).tar.gz
PKG_HASH:=ef6f74fd45e95ee4ef7f9e19ebe5b075ca6b7fbe0140612b2a161abafb7ee179

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Philip Prindeville <philipp@redfish-solutions.com>

include $(INCLUDE_DIR)/package.mk

define Package/libjemalloc
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Jemalloc general purpose allocator
  URL:=https://github.com/jemalloc/jemalloc
  DEPENDS:= +libunwind +libstdcpp
  ABI_VERSION:=2
endef

define Package/libjemalloc/Description
  Jemalloc is a general purpose malloc(3) implementation that emphasizes
  fragmentation avoidance and scalable concurrency support.
endef

CONFIGURE_ARGS += \
	--enable-shared \
	--disable-static \
	--enable-prof \
	--enable-prof-libunwind \
	--enable-readlinkat

MAKE_FLAGS += enable_doc=0

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/libjemalloc.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/include/jemalloc
	$(CP) $(PKG_BUILD_DIR)/include/jemalloc/*.h $(1)/usr/include/jemalloc
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_BUILD_DIR)/jemalloc.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libjemalloc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/libjemalloc.so.$(ABI_VERSION) $(1)/usr/lib
	$(LN) libjemalloc.so.$(ABI_VERSION) $(1)/usr/lib/libjemalloc.so
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/{jemalloc-config,jemalloc.sh,jeprof} $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libjemalloc))
