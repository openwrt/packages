#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=seafile-ccnet
PKG_VERSION:=4.1.2
PKG_RELEASE=$(PKG_SOURCE_VERSION)
PKG_LICENSE:=GPL-3.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/haiwen/ccnet.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=a73109f09af4ecc49cdc4c57cdde51b38e15c31a
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/seafile-ccnet
    SECTION:=net
    CATEGORY:=Network
    TITLE:=Seafile server - ccnet component
    MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
    URL:=http://seafile.com/
    DEPENDS:=+libsearpc +libevent2 +libopenssl \
		+glib2 +python +libzdb +libuuid \
		+libpthread +libsqlite3 +jansson $(ICONV_DEPENDS)
endef

define Package/seafile-ccnet/description
   Ccnet is a framework for writing networked applications in C.
endef

CONFIGURE_ARGS += --disable-client \
		    --enable-server \
		    --disable-ldap \
		    --disable-cluster \
		    --enable-python \
		    --disable-server-pkg \
		    --disable-static-build \
		    --disable-compile-demo \
		    --disable-console

PKG_BUILD_DEPENDS:=vala/host \
		   libsearpc/host

TARGET_LDFLAGS += -Wl,-rpath-link=$(STAGING_DIR)/usr/lib -liconv \
		    -L$(STAGING_DIR)/usr/lib/mysql -lmysqlclient -lz

define Package/seafile-ccnet/install
	$(INSTALL_DIR) $(1)/usr/{bin,lib}
	$(INSTALL_DIR) $(1)/usr/lib/python2.7/site-packages
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/ccnet* $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/python2.7/site-packages/ccnet $(1)/usr/lib/python2.7/site-packages/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libccnet.so* $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/ccnet* $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libccnet.pc $(1)/usr/lib/pkgconfig/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libccnet.a $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libccnet.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,seafile-ccnet))
