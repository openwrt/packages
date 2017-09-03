#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pcre
PKG_VERSION:=8.41
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/
PKG_MD5SUM:=c160d22723b1670447341b08c58981c1
PKG_MAINTAINER:=Thomas Heil <heil@terminal-consulting.de>

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENCE

PKG_FIXUP:=autoreconf

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libpcre/default
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=http://www.pcre.org/
endef

define Package/libpcre
  $(call Package/libpcre/default)
  TITLE:=A Perl Compatible Regular Expression library
endef

define Package/libpcre16
  $(call Package/libpcre/default)
  TITLE:=A Perl Compatible Regular Expression library (16bit support)
endef

define Package/libpcrecpp
  $(call Package/libpcre/default)
  TITLE:=C++ wrapper for Perl Compatible Regular Expression library
  DEPENDS:=+libpcre +libstdcpp
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--enable-utf8 \
	--enable-unicode-properties \
	--enable-pcre16 \
	--with-match-limit-recursion=16000 \

ifneq ($(CONFIG_PACKAGE_libpcrecpp),)
  CONFIGURE_ARGS+= --enable-cpp
else
  CONFIGURE_ARGS+= --disable-cpp
endif

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)"

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/pcre-config $(1)/usr/bin/

	$(INSTALL_DIR) $(2)/bin
	$(LN) $(STAGING_DIR)/usr/bin/pcre-config $(2)/bin

	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/pcre*.h $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpcre*.{a,so*} $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libpcre*.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libpcre/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpcre{,posix}.so.* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpcre.so $(1)/usr/lib/
endef

define Package/libpcre16/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpcre16.so* $(1)/usr/lib/
endef

define Package/libpcrecpp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpcrecpp.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libpcre))
$(eval $(call BuildPackage,libpcre16))
$(eval $(call BuildPackage,libpcrecpp))
