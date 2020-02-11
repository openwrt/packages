include $(TOPDIR)/rules.mk

PKG_NAME:=rpcsvc-proto
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/thkukuk/rpcsvc-proto.git
PKG_SOURCE_DATE:=2020-01-16
PKG_SOURCE_VERSION:=daba1f3aa715551bd83770053a15153f0e40d27f
PKG_MIRROR_HASH:=38ac6ad69327d4498cebc5b97519210f0643a8c47a3a3409cbae01806631694b

PKG_MAINTAINER:=Andy Walsh <andy.walsh44+github@gmail.com>
PKG_LICENSE:=BSD-3-clause
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_REMOVE_FILES:=autogen.sh
PKG_INSTALL:=1

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
	$(SED) 's,.*/rpcgen/rpcgen,\t$(STAGING_DIR_HOSTPKG)/bin/rpcgen,' $(PKG_BUILD_DIR)/rpcsvc/Makefile.am
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/rpcsvc $(1)/usr/include/
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,rpcsvc-proto))
