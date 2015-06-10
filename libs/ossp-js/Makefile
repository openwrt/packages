#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=js
PKG_VERSION:=1.6.20070208
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=ftp://ftp.ossp.org/pkg/lib/js/
PKG_MD5SUM:=07f6cad7e03fd74a949588c3d4b333de
PKG_MAINTAINER:=Oliver Ertl <oliver-ertl@t-online.de>

PKG_LICENSE:=MPL-1.0
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_REMOVE_FILES:=aclocal.m4 libtool.m4

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

define Package/js/Default
 TITLE:=Mozilla JavaScript Engine
 URL:=http://www.ossp.org/pkg/lib/js/
endef

define Package/js
$(call Package/js/Default)
 SECTION:=lang
 CATEGORY:=Languages
 SUBMENU:=JavaScript
 TITLE+= (interpreter)
 DEPENDS+= +libjs +libreadline +libncurses
endef

define Package/libjs
$(call Package/js/Default)
 SECTION:=libs
 CATEGORY:=Libraries
 TITLE+= (library)
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--with-dso \
	--with-editline \
	--with-file \
	--without-perl

define Build/Configure
	(cd $(PKG_BUILD_DIR); rm -f config.cache; \
		./configure \
			--prefix=/usr \
			--exec-prefix=/usr \
			--bindir=/usr/bin \
			--datadir=/usr/share \
			--includedir=/usr/include \
			--infodir=/usr/share/info \
			--libdir=/usr/lib \
			--libexecdir=/usr/lib \
			--localstatedir=/var \
			--mandir=/usr/share/man \
			--sbindir=/usr/sbin \
			--sysconfdir=/etc \
			$(DISABLE_NLS) \
			--disable-shared \
			--enable-static \
	);
	$(MAKE) -C $(PKG_BUILD_DIR) src/jsautocfg.h
	$(call Build/Configure/Default)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(2)/bin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/js-config \
		$(2)/bin/
	$(SED) \
		's,^\(prefix\|exec_prefix\)=.*,\1=$(STAGING_DIR)/usr,g' \
		$(2)/bin/js-config

	$(INSTALL_DIR) $(1)/usr/include
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/js \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libjs.{la,so*} \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/js.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/js/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/js \
		$(1)/usr/bin/
endef

define Package/libjs/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libjs.so.* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,js))
$(eval $(call BuildPackage,libjs))
