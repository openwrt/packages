#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=c-icap-server
PKG_SOURCE_NAME:=C_ICAP
PKG_VERSION:=0.5.7
PKG_RELEASE:=1

PKG_PROTO:=git
PKG_SOURCE:=$(PKG_SOURCE_NAME)_$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/c-icap/c-icap-server/tar.gz/$(PKG_SOURCE_NAME)_$(PKG_VERSION)?
PKG_HASH:=79a228a1145ada3a96dfe0abdbfca2103f0d52f5c75117d71998a07433a9c5d7

PKG_LICENSE:=LGPL-2.1
PKG_MAINTAINER:=Nishant Sharma <nishant@hopbox.in>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SOURCE_NAME)_$(PKG_VERSION)


PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libicapapi/Default
	URL:=http://c-icap.sourceforge.net/
	DEPENDS:=+libc +libpcre +libpthread +librt +zlib +libbz2 +libopenssl +libdb47 +libopenldap
	MAINTAINER:=Nishant Sharma <nishant@hopbox.in>
endef

define Package/libicapapi
	$(call Package/libicapapi/Default)
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=A library to simplify ICAP programming
endef

define Package/libicapapi/description
	The goal of libicapapi is to simplify ICAP programming.
endef

define Package/$(PKG_NAME)
	$(call Package/libicapapi/Default)
	SUBMENU:=Web Servers/Proxies
	SECTION:=net
	CATEGORY:=Network
	DEPENDS+=+libicapapi
	TITLE:=An ICAP server
endef

define Package/$(PKG_NAME)/description
	c-icap is an implementation of an ICAP server. It can be
	used with HTTP proxies that support the ICAP protocol to
	implement content adaptation and filtering services.
endef

CONFIGURE_VARS += \
	ac_cv_10031b_ipc_sem=yes \
	ac_cv_fcntl=yes

CONFIGURE_ARGS += \
	--config-cache \
	--sysconfdir=/etc/c-icap 
	
define Build/Prepare
	$(call Build/Prepare/Default)
	echo $(PKG_VERSION) > $(PKG_BUILD_DIR)/VERSION.m4
endef

define Build/InstallDev
	$(INSTALL_DIR) $(2)/bin $(1)/usr/bin $(1)/usr/lib $(1)/usr/include
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/c-icap-config $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/c-icap-libicapapi-config $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/c_icap $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libicapapi.{la,so*} $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/c_icap $(1)/usr/include
	$(SED) 's,^INCDIR=/usr/include,INCDIR=$(STAGING_DIR)/usr/include,g' $(1)/usr/bin/c-icap-config
	$(SED) 's,^INCDIR2=/usr/include/c_icap,INCDIR2=$(STAGING_DIR)/usr/include/c_icap,g' $(1)/usr/bin/c-icap-config
	$(SED) 's,^INCDIR=/usr/include,INCDIR=$(STAGING_DIR)/usr/include,g' $(1)/usr/bin/c-icap-libicapapi-config
	$(SED) 's,^INCDIR2=/usr/include/c_icap,INCDIR2=$(STAGING_DIR)/usr/include/c_icap,g' $(1)/usr/bin/c-icap-libicapapi-config
	ln -sf $(STAGING_DIR)/usr/bin/c-icap-config $(2)/bin/
	ln -sf $(STAGING_DIR)/usr/bin/c-icap-libicapapi-config $(2)/bin/
endef

define Package/libicapapi/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libicapapi.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/c_icap
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/c_icap/* $(1)/usr/lib/c_icap
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/c-icap
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/c-icap.conf $(1)/etc/c-icap

	$(INSTALL_DIR) $(1)/etc/c-icap
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/c-icap.magic $(1)/etc/c-icap

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/c-icap.init $(1)/etc/init.d/c-icap
endef

$(eval $(call BuildPackage,libicapapi))
$(eval $(call BuildPackage,$(PKG_NAME)))
