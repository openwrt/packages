#
# Copyright (C) 2011-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=p11-kit
PKG_VERSION:=0.24.1
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/p11-glue/p11-kit/releases/download/$(PKG_VERSION)
PKG_HASH:=d8be783efd5cd4ae534cee4132338e3f40f182c3205d23b200094ec85faaaef8

PKG_MAINTAINER:=Nikos Mavrogiannopoulos <n.mavrogiannopoulos@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:p11-kit_project:p11-kit

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/p11-kit
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A library that provides a way to load and enumerate PKCS11 modules.
  URL:=https://p11-glue.github.io/p11-glue/p11-kit.html
  DEPENDS:=+libtasn1 +libpthread
endef

define Package/p11-kit/description
  Provides a way to load and enumerate PKCS11 modules. Provides a
  standard configuration setup for installing PKCS11 modules in such a
  way that they are discoverable.
endef

define Package/p11-kit-utils
  SECTION:=libs
  CATEGORY:=Utilities
  TITLE:=A library that provides a way to load and enumerate PKCS11 modules.
  URL:=https://p11-glue.github.io/p11-glue/p11-kit.html
  DEPENDS:=+libtasn1 +libpthread +p11-kit
endef

define Package/p11-kit-utils/description
  Run a server process that exposes PKCS#11 module remotely.
  $ p11-kit server pkcs11:token1 pkcs11:token2 ...
  $ p11-kit server --provider /path/to/pkcs11-module.so pkcs11:token1 pkcs11:token2 ...

  This launches a server that exposes the given PKCS#11 tokens on a local socket. The tokens
  must belong to the same module. To access the socket, use p11-kit-client.so module. The
  server address and PID are printed as a shell-script snippet which sets the appropriate
  environment variable: P11_KIT_SERVER_ADDRESS and P11_KIT_SERVER_PID
endef

TARGET_LDFLAGS += -Wl,--gc-sections

MESON_ARGS += \
	-Dhash_impl=internal \
	-Dlibffi=disabled \
	-Dtrust_module=disabled \
	-Dstrict=false \
	-Dsystemd=disabled \
	-Dgtk_doc=false \
	-Dman=false \
	-Dnls=false

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/p11-kit-1/p11-kit/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/p11-kit-1/p11-kit/* $(1)/usr/include/p11-kit-1/p11-kit/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libp11-kit.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/p11-kit-1.pc $(1)/usr/lib/pkgconfig/p11-kit-1.pc
endef

define Package/p11-kit/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libp11-kit.so.* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc/pkcs11/modules/
ifneq ($(CONFIG_PACKAGE_libopensc),)
	$(CP) ./files/opensc.module $(1)/etc/pkcs11/modules/
endif
endef

define Package/p11-kit-utils/install
	$(INSTALL_DIR) $(1)/etc/pkcs11/modules/
	$(CP) ./files/p11kitclient.module $(1)/etc/pkcs11/modules/
	$(INSTALL_DIR) $(1)/usr/lib/pkcs11
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkcs11/p11-kit-client.so $(1)/usr/lib/pkcs11
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/p11-kit $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/libexec/p11-kit
	$(CP) $(PKG_INSTALL_DIR)/usr/libexec/p11-kit/* $(1)/usr/libexec/p11-kit
endef

$(eval $(call BuildPackage,p11-kit))
$(eval $(call BuildPackage,p11-kit-utils))
