#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=xmlrpc-c
PKG_VERSION:=1.51.07
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=@SF/xmlrpc-c/Xmlrpc-c%20Super%20Stable/$(PKG_VERSION)
PKG_HASH:=84d20ae33f927582f821d61c0b9194aefbf1d7924590a13fa9da5ae1698aded9

PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>
PKG_LICENSE:=VARIOUS
PKG_LICENSE_FILES:=doc/COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/xmlrpc-c
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=XML-RPC library
  URL:=http://xmlrpc-c.sourceforge.net/
  DEPENDS+= +libpthread +XMLRPC_C_CLIENT:libcurl +XMLRPC_C_LIBXML2:libxml2
endef

define Package/xmlrpc-c/config
  source "$(SOURCE)/Config.in"
endef

define Package/xmlrpc-c/description
    Programming library for writing an XML-RPC server or client in C or C++.
    XML-RPC is a standard network protocol to allow a client program to make
    a simple remote procedure call (RPC) type request of a server.
endef

CONFIGURE_ARGS+= \
	--disable-wininet-client \
	--disable-libwww-client \
	--disable-abyss-server \
	--disable-cgi-server \
	--disable-cplusplus \
	--disable-abyss-threads \
	--without-libwww-ssl \
	$(if $(CONFIG_XMLRPC_C_LIBXML2),--enable-libxml2-backend,--disable-libxml2-backend)

define Build/Compile
	( cd $(PKG_BUILD_DIR)/lib/expat/gennmtab && cc -I$(PKG_BUILD_DIR) -c gennmtab.c -o gennmtab.o && cc -o gennmtab  gennmtab.o )
	$(call Build/Compile/Default)
endef

define Build/InstallDev
	$(INSTALL_DIR) \
		$(1)/usr/include \
		$(1)/usr/lib \
		$(1)/usr/bin \
		$(2)/bin
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/* \
		$(1)/usr/include/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libxmlrpc*.{a,so*} \
		$(1)/usr/lib/
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/xmlrpc-c-config \
		$(2)/bin/
	$(SED) 's,PREFIX="/usr",PREFIX="$(STAGING_DIR)/usr",g' $(2)/bin/xmlrpc-c-config
	$(SED) \
		's,HEADERINST_DIR="/usr/include",HEADERINST_DIR="$(STAGING_DIR)/usr/include",g' \
		$(2)/bin/xmlrpc-c-config
	$(SED) \
		's,LIBINST_DIR="/usr/lib",LIBINST_DIR="$(STAGING_DIR)/usr/lib",g' \
		$(2)/bin/xmlrpc-c-config
endef

define Package/xmlrpc-c/install
	$(INSTALL_DIR) \
		$(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libxmlrpc.so* \
		$(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libxmlrpc_util.so* \
		$(1)/usr/lib/

ifeq ($(CONFIG_XMLRPC_C_INTERNAL),y)
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libxmlrpc_xmltok.so* \
		$(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libxmlrpc_xmlparse.so* \
		$(1)/usr/lib/
endif

ifeq ($(CONFIG_XMLRPC_C_CLIENT),y)
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libxmlrpc_client* \
		$(1)/usr/lib/
endif

ifeq ($(CONFIG_XMLRPC_C_SERVER),y)
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libxmlrpc_server.so* \
		$(1)/usr/lib/
endif

endef

$(eval $(call BuildPackage,xmlrpc-c))
