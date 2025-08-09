include $(TOPDIR)/rules.mk

PKG_NAME:=rpcsvc-proto
PKG_VERSION:=1.4.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/thkukuk/rpcsvc-proto/releases/download/v$(PKG_VERSION)
PKG_HASH:=81c3aa27edb5d8a18ef027081ebb984234d5b5860c65bd99d4ac8f03145a558b

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

HOST_BUILD_DEPENDS:=gettext-full/host
PKG_BUILD_DEPENDS:=rpcsvc-proto/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/rpcsvc-proto
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=rpcgen and rpcsvc proto.x files from glibc
  URL:=https://github.com/thkukuk/rpcsvc-proto
  DEPENDS:=$(INTL_DEPENDS)
  BUILDONLY:=1
endef

define Package/rpcsvc-proto/description
  This package contains rpcsvc proto.x files from glibc, which are missing in libtirpc.
  Additional it contains rpcgen, which is needed to create header files and sources from protocol files.
endef

# need to use host tool
define Build/Prepare
	$(Build/Prepare/Default)
	$(SED) 's,.*/rpcgen/rpcgen,\t$(STAGING_DIR_HOSTPKG)/bin/rpcgen,' $(PKG_BUILD_DIR)/rpcsvc/Makefile.in
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/rpcsvc $(1)/usr/include/
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,rpcsvc-proto))
