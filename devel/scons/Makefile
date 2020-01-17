#
# Copyright (C) 2011-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=scons
PKG_VERSION:=3.1.2

PKG_SOURCE:=$(PKG_NAME)-local-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/scons
PKG_HASH:=642e90860b746fa18fac08c7a22de6bfa86110ae7c56d7f136f7e5fb0d8f4f44

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=scons-LICENSE
PKG_MAINTAINER:=

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

HOST_UNPACK:=$(DECOMPRESS_CMD) $(HOST_TAR) -C $(HOST_BUILD_DIR) $(TAR_OPTIONS)

define Package/scons
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=scons
  HIDDEN:=1
endef

define Package/scons/description
  SCons is an Open Source software construction tool—that is, a
  next-generation build tool. Think of SCons as an improved, cross-platform
  substitute for the classic Make utility with integrated functionality
  similar to autoconf/automake and compiler caches such as ccache. In short,
  SCons is an easier, more reliable and faster way to build software.
endef

define Host/Configure
endef

define Host/Compile
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/bin
	for py in $(HOST_BUILD_DIR)/*.py; do \
		bin=$$$${py%.py} ; \
		$(CP) $$$$py $$$$bin ; \
		$(SED) '1c#!$(STAGING_DIR_HOST)/bin/python' $$$$bin ; \
		$(INSTALL_BIN) $$$$bin $(STAGING_DIR_HOSTPKG)/bin/ ; \
	done

	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/lib/scons
	$(CP) $(HOST_BUILD_DIR)/scons-local-$(PKG_VERSION)/* $(STAGING_DIR_HOSTPKG)/lib/scons/
endef

$(eval $(call BuildPackage,scons))
$(eval $(call HostBuild))
