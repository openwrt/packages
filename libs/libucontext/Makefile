include $(TOPDIR)/rules.mk

PKG_NAME:=libucontext
PKG_VERSION:=1.3.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/kaniini/libucontext
PKG_SOURCE_VERSION:=$(PKG_NAME)-$(PKG_VERSION)
PKG_MIRROR_HASH:=eef55c05aca03c6d62672838638f49daa95ab8f9bf87126df32cedfe150e333c

PKG_MAINTAINER:=Volker Christian <me@vchrist.at>
PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_FLAGS:=no-mips16

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
  This package is a development package aimed to be linked to
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
