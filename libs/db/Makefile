#
# Copyright (C) 2009-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=db
PKG_VERSION:=5.3.28
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://download.oracle.com/berkeley-db/
PKG_HASH:=e0a992d740709892e81f9d93f06daf305cf73fb81b545afe72478043172c3628

PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>
PKG_LICENSE:=Sleepycat
PKG_LICENSE_FILES:=LICENSE

PKG_FIXUP:=autoreconf
PKG_BUILD_DEPENDS:=libxml2
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libdb47
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Berkeley DB library
  URL:=http://www.oracle.com/us/products/database/berkeley-db
  PROVIDES:=libdb47-full
  ABI_VERSION:=5
endef

define Package/libdb47/description
  Berkeley DB library.
endef

define Package/libdb47xx
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libdb47 +libstdcpp
  TITLE:=Berkeley DB library for C++
  URL:=http://www.oracle.com/us/products/database/berkeley-db
  PROVIDES:=libdb47xx-full
  ABI_VERSION:=5
endef

define Package/libdb47xx/description
  Berkeley DB library C++ wrapper.
endef

CONFIGURE_PATH = build_unix
CONFIGURE_CMD = ../dist/configure

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--disable-java \
	--with-mutex=POSIX/pthreads/library \
	--disable-tcl \
	--enable-compat185 \
	--disable-debug \
	$(if $(CONFIG_PACKAGE_libdb47xx),--enable-cxx,--disable-cxx)

TARGET_CFLAGS += $(FPIC) -std=gnu17

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/build_unix \
		DESTDIR="$(PKG_INSTALL_DIR)" all
	$(MAKE) -C $(PKG_BUILD_DIR)/build_unix \
		DESTDIR="$(PKG_INSTALL_DIR)" install
endef

define Package/libdb47/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libdb-*.so $(1)/usr/lib/
endef

define Package/libdb47xx/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libdb_cxx-*.so $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/db.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/db_cxx.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libdb*.{a,so} $(1)/usr/lib
endef

$(eval $(call BuildPackage,libdb47))
$(eval $(call BuildPackage,libdb47xx))
