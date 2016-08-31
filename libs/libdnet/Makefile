#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libdnet
PKG_VERSION:=1.12
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://libdnet.googlecode.com/files/
PKG_MD5SUM:=9253ef6de1b5e28e9c9a62b882e44cc9

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_LICENSE:=BSD
PKG_MAINTAINER:=Luka Perkov <luka@openwrt.org>

include $(INCLUDE_DIR)/package.mk

define Package/libdnet
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Low-level network library
  URL:=http://sourceforge.net/projects/libdnet/
endef

define Package/libdnet/description
 libdnet is a library of simplified, portable interface to several low-level
 networking routines.
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--without-check \
	--without-python

CONFIGURE_VARS += \
	ac_cv_dnet_bsd_bpf=no

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS) -D_GNU_SOURCE"

define Build/InstallDev
	$(INSTALL_DIR) $(2)/bin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/dnet-config \
		$(2)/bin/
	$(SED) \
		's,^\(prefix\|exec_prefix\)=.*,\1=$(STAGING_DIR)/usr,g' \
		$(2)/bin/dnet-config

	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DATA)\
		$(PKG_INSTALL_DIR)/usr/include/dnet.h \
		$(1)/usr/include/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/dnet \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libdnet.{la,a,so*} \
		$(1)/usr/lib/
endef

define Package/libdnet/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libdnet.so.* \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/sbin/dnet \
		$(1)/usr/sbin/
endef

$(eval $(call BuildPackage,libdnet))
