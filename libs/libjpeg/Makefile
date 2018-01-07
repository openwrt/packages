#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=jpeg
PKG_VERSION:=9a
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)src.v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.ijg.org/files
PKG_HASH:=3a753ea48d917945dd54a2d97de388aa06ca2eb1066cbfdc6652036349fe05a7

PKG_MAINTAINER:=Jo-Philipp Wich <jo@mein.io>
PKG_LICENSE:=IJG
PKG_LICENSE_FILES:=README

PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=libtool

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/jpeg/Default
  TITLE:=The Independent JPEG Group's JPEG
  URL:=http://www.ijg.org/
endef

define Package/libjpeg
  $(call Package/jpeg/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= runtime library
endef

define Package/jpeg-tools
  $(call Package/jpeg/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Image Manipulation
  DEPENDS:=+libjpeg
  TITLE+= manipulation tools
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \

HOST_CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		LIBTOOL="./libtool --tag=CC" \
		prefix="$(PKG_INSTALL_DIR)/usr" \
		exec_prefix="$(PKG_INSTALL_DIR)/usr" \
		all
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		install
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/jpeglib.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/jpegint.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/j{config,error,morecfg}.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjpeg.{a,so*} $(1)/usr/lib/
endef

define Package/libjpeg/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjpeg.so.* $(1)/usr/lib/
endef

define Package/jpeg-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/*jpeg* $(1)/usr/bin/
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,libjpeg))
$(eval $(call BuildPackage,jpeg-tools))
