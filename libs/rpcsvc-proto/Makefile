include $(TOPDIR)/rules.mk

PKG_NAME:=rpcsvc-proto
PKG_VERSION:=1.4
PKG_RELEASE:=2

PKG_SOURCE_URL:=https://github.com/thkukuk/rpcsvc-proto/releases/download/v$(PKG_VERSION)/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=867e46767812784d8dda6d8d931d6fabb30168abb02d87a2a205be6d5a2934a7

PKG_MAINTAINER:=Andy Walsh <andy.walsh44+github@gmail.com>
PKG_LICENSE:=BSD-3-clause
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_REMOVE_FILES:=autogen.sh
PKG_INSTALL:=1

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
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rpcgen $(1)/usr/bin/
endef

# do we need rpcgen on target?
define Package/rpcsvc-proto/install
	# $(INSTALL_DIR) $(1)/usr/bin
	# $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rpcgen $(1)/usr/bin/
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,rpcsvc-proto))
