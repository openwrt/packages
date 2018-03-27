# 
# Copyright (C) 2006-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libtirpc
PKG_VERSION:=1.0.3
PKG_RELEASE:=1

PKG_SOURCE_URL:=@SF/libtirpc
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=86c3a78fc1bddefa96111dd233124c703b22a78884203c55c3e06b3be6a0fd5e

PKG_MAINTAINER:=Andy Walsh <andy.walsh44+github@gmail.com>
PKG_LICENSE:=BSD-3-Clause

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libtirpc
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library TI RPC for RPC bindings
  URL:=http://libtirpc.sourceforge.net/
  DEPENDS:=+libpthread
endef

CONFIGURE_ARGS += --disable-gssapi
# Info from Buildroot Makefile
# getrpcby{number,name} are only provided if 'GQ' is defined
TARGET_CFLAGS += -DGQ
#CONFIGURE_VARS += \
#	GSSGLUE_LIBS="-lkrb5 -lk5crypto -l:libcom_err.so.3 -lkeyutils -lresolv -gssapi_krb5" \
#	GSSGLUE_CFLAGS=-I$(STAGING_DIR)/usr/include/krb5/

#EXTRA_LDFLAGS := -lgssapi_krb5

define Package/libtirpc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtirpc.so* $(1)/usr/lib
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtirpc.{a,so*} $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include
	$(SED) 's,/usr,${STAGING_DIR}/usr,g' $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libtirpc.pc
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libtirpc.pc $(1)/usr/lib/pkgconfig/libtirpc.pc
endef

$(eval $(call BuildPackage,libtirpc))
