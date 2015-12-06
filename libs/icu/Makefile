#
# Copyright (C) 2006-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=icu4c
PKG_VERSION:=55.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-55_1-src.tgz
PKG_SOURCE_URL:=http://download.icu-project.org/files/icu4c/55.1
PKG_MD5SUM:=e2d523df79d6cb7855c2fbe284f4db29

PKG_LICENSE:=ICU-1.8.1+
PKG_LICENSE_FILES:=license.html

PKG_MAINTAINER:=Mirko Vogt <mirko@openwrt.org>

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_BUILD_DEPENDS:=icu/host


include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

TAR_OPTIONS+= icu/source --strip-components 2
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

define Package/icu
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=International Components for Unicode
  URL:=http://icu-project.org
  DEPENDS:=+libstdcpp +libpthread
endef

define Build/Configure
	$(call Build/Configure/Default, \
		--disable-debug \
		--enable-release \
		--enable-shared \
		--enable-static \
		--enable-draft \
		--enable-renaming \
		--disable-tracing \
		--disable-extras \
		--enable-dyload \
		--enable-layout \
		--enable-layoutex \
		--disable-tools \
		--disable-tests \
		--disable-samples \
		--with-cross-build="$(HOST_BUILD_DIR)" \
	)
endef

define Build/InstallDev
	$(INSTALL_DIR) \
		$(1)/usr/include

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/* \
		$(1)/usr/include/

	$(INSTALL_DIR) \
		$(1)/usr/lib

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/* \
		$(1)/usr/lib/
endef

define Host/install
endef

define Package/icu/install
	$(INSTALL_DIR) \
		$(1)/usr/lib

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/*.so.* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,icu))
$(eval $(call HostBuild))
