include $(TOPDIR)/rules.mk

PKG_NAME:=libucontext
PKG_VERSION:=1.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/kaniini/libucontext/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=2657e087c493263e7bbbde152a5bc08ce22dc5a7970887ac4fd251b90b58401f

PKG_MAINTAINER:=Volker Christian <me@vchrist.at>
PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_FLAGS:=no-mips16
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/libucontext
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libucontext is a library which provides the ucontext.h C API
  URL:=https://github.com/kaniini/libucontext
  DEPENDS:=@USE_MUSL
endef

define Package/libucontext-tests
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Test applications for libucontext
  URL:=https://github.com/kaniini/libucontext
  DEPENDS:=libucontext
endef

define Package/libucontext/description
  Thie package is a development package aimed to be linked to
  libraries/applications which need the SYS-V ucontext API.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libucontext $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libucontext* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libucontext.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libucontext/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libucontext*.so.* $(1)/usr/lib/
endef

define Package/libucontext-tests/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(MESON_BUILD_DIR)/test_libucontext_posix $(1)/usr/bin/
	$(INSTALL_BIN) $(MESON_BUILD_DIR)/test_libucontext $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libucontext))
$(eval $(call BuildPackage,libucontext-tests))
