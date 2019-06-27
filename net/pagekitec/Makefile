#
# Copyright (C) 2012-2018 Karl Palsson <karlp@tweak.net.au>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pagekitec
PKG_VERSION:=0.91.190530
PKG_RELEASE:=1

PKG_SOURCE:=libpagekitec-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/pagekite/libpagekite/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=c812815aae6f100212b7d6f662370a0634151fabb59f028126a59c4083a6d26d
PKG_BUILD_DIR:=$(BUILD_DIR)/libpagekitec-$(PKG_VERSION)

PKG_MAINTAINER:= Karl Palsson <karlp@tweak.net.au>
PKG_LICENSE:=Apache-2.0

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/pagekitec/default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Make localhost servers publicly visible.
  URL:=https://pagekite.net/wiki/Floss/LibPageKite/
  DEPENDS:=+libopenssl +libpthread +libev
endef

define Package/libpagekite
  $(call Package/pagekitec/default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= (library)
endef

define Package/pagekitec
  $(call Package/pagekitec/default)
  DEPENDS:=+libpagekite
endef

define Package/pagekitec/default/description
PageKite is a system for running publicly visible servers (generally
web servers) on machines without a direct connection to the Internet,
such as mobile devices or computers behind restrictive firewalls.
PageKite works around NAT, firewalls and IP-address limitations by
using a combination of tunnels and reverse proxies.

This package provides an implementation of the PageKite Protocol in C,
optimized for high-performance or embedded applications.

endef

define Package/libpagekite/description
  $(call Package/pagekitec/default/description)

This package contains the core library
endef

define Package/pagekitec/description
  $(call Package/pagekitec/default/description)

This package contains a basic backend useful for exposing http/ssh servers.

Basic UCI support for configuring this backend is also included.
endef

define Package/pagekitec/conffiles
/etc/config/pagekitec
endef

CONFIGURE_ARGS += --without-java

define Build/Configure
	(cd $(PKG_BUILD_DIR); ./autogen.sh );
	$(call Build/Configure/Default)
endef

#this installs files into ./staging_dir/. so that you can cross compile from the host
define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/{include,lib/pkgconfig}
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libpagekite/pagekite.h $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpagekite.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig
endef

define Package/libpagekite/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpagekite.so* $(1)/usr/lib
endef

define Package/pagekitec/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/pagekitec $(1)/usr/bin
endef

$(eval $(call BuildPackage,pagekitec))
$(eval $(call BuildPackage,libpagekite))
