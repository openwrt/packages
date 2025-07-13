#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=xmlrpc-c
PKG_VERSION:=1.60.05
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=@SF/xmlrpc-c/Xmlrpc-c%20Super%20Stable/$(PKG_VERSION)
PKG_HASH:=67d860062459ea2784c07b4d7913319d9539fa729f534378e8e41c8918f2adf6

PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>
PKG_LICENSE:=VARIOUS
PKG_LICENSE_FILES:=doc/COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/xmlrpc-c/Default
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=XML-RPC library
  URL:=http://xmlrpc-c.sourceforge.net/
endef

define Package/xmlrpc-c-common
  $(call Package/xmlrpc-c/Default)
  TITLE+= - common
  DEPENDS+= +libpthread
  HIDDEN:=1
endef

define Package/xmlrpc-c-internal
  $(call Package/xmlrpc-c/Default)
  TITLE+= (uses internal expat variant)
  DEPENDS:=+xmlrpc-c-common
  PROVIDES:=xmlrpc-c
  VARIANT:=internal
endef

define Package/xmlrpc-c-libxml2
  $(call Package/xmlrpc-c/Default)
  TITLE+= (uses libxml2)
  DEPENDS:=+xmlrpc-c-common +libxml2
  PROVIDES:=xmlrpc-c
  VARIANT:=libxml2
endef

define Package/xmlrpc-c-client
  $(call Package/xmlrpc-c/Default)
  TITLE+= - client
  DEPENDS:=+xmlrpc-c +libcurl
endef

define Package/xmlrpc-c-server
  $(call Package/xmlrpc-c/Default)
  TITLE+= - server
  DEPENDS:=+xmlrpc-c
endef

define Package/xmlrpc-c-abyss
  $(call Package/xmlrpc-c/Default)
  TITLE+= - abyss
  DEPENDS:=+xmlrpc-c-common
endef

define Package/xmlrpc-c-server-abyss
  $(call Package/xmlrpc-c/Default)
  TITLE+= - abyss server
  DEPENDS:=+xmlrpc-c-server +xmlrpc-c-abyss
endef

define Package/xmlrpc-c/description/Default
    Programming library for writing an XML-RPC server or client in C or C++.
    XML-RPC is a standard network protocol to allow a client program to make
    a simple remote procedure call (RPC) type request of a server.
endef

Package/xmlrpc-c-common/description = $(Package/xmlrpc-c/description/Default)
Package/xmlrpc-c-libxml2/description = $(Package/xmlrpc-c/description/Default)
Package/xmlrpc-c-internal/description = $(Package/xmlrpc-c/description/Default)

Package/xmlrpc-c-libxml2/description += Uses external libxml2 library (quite big)
Package/xmlrpc-c-internal/description += Uses internal expat variant (stripped down)

CONFIGURE_ARGS+= \
	--disable-wininet-client \
	--disable-libwww-client \
	--disable-cgi-server \
	--disable-cplusplus \
	--without-libwww-ssl \
	--disable-abyss-openssl

ifeq ($(BUILD_VARIANT),libxml2)
	CONFIGURE_ARGS += \
		--enable-libxml2-backend
endif

ifeq ($(BUILD_VARIANT),internal)
	CONFIGURE_ARGS += \
		--disable-libxml2-backend
endif

define Build/Compile
	( cd $(PKG_BUILD_DIR)/lib/expat/gennmtab && cc -I$(PKG_BUILD_DIR) -c gennmtab.c -o gennmtab.o && cc -o gennmtab gennmtab.o )
	$(call Build/Compile/Default)
endef

TARGET_VARIANT=$(if $(ALL_VARIANTS),$(if $(VARIANT),$(VARIANT),$(firstword $(ALL_VARIANTS))))
ifeq ($(if $(TARGET_VARIANT),$(BUILD_VARIANT)),$(TARGET_VARIANT))
  define Build/InstallDev
	$(INSTALL_DIR) \
		$(1)/usr/include \
		$(1)/usr/lib \
		$(1)/usr/bin \
		$(1)/usr/lib/pkgconfig \
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
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc \
		$(1)/usr/lib/pkgconfig/
  endef
endif

define Package/xmlrpc-c-libxml2/install
	$(INSTALL_DIR) \
		$(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libxmlrpc.so* \
		$(1)/usr/lib/
endef

define Package/xmlrpc-c-internal/install
	$(INSTALL_DIR) \
		$(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libxmlrpc.so* \
		$(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libxmlrpc_xmltok.so* \
		$(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libxmlrpc_xmlparse.so* \
		$(1)/usr/lib/
endef

define Package/xmlrpc-c-server/install
	$(INSTALL_DIR) \
		$(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libxmlrpc_server.so* \
		$(1)/usr/lib/
endef

define Package/xmlrpc-c-abyss/install
	$(INSTALL_DIR) \
		$(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libxmlrpc_abyss.so* \
		$(1)/usr/lib/
endef

define Package/xmlrpc-c-server-abyss/install
	$(INSTALL_DIR) \
		$(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libxmlrpc_server_abyss.so* \
		$(1)/usr/lib/
endef

define Package/xmlrpc-c-client/install
	$(INSTALL_DIR) \
		$(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libxmlrpc_client* \
		$(1)/usr/lib/
endef

define Package/xmlrpc-c-common/install
	$(INSTALL_DIR) \
		$(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libxmlrpc_util.so* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,xmlrpc-c-common))
$(eval $(call BuildPackage,xmlrpc-c-libxml2))
$(eval $(call BuildPackage,xmlrpc-c-internal))
$(eval $(call BuildPackage,xmlrpc-c-server))
$(eval $(call BuildPackage,xmlrpc-c-abyss))
$(eval $(call BuildPackage,xmlrpc-c-server-abyss))
$(eval $(call BuildPackage,xmlrpc-c-client))
