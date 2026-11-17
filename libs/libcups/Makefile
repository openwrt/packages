#
# Copyright (C) 2006-2012 OpenWrt.org
# Copyright (C) 2017-2018 Luiz Angelo Daros de Luca <luizluca@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cups
PKG_VERSION:=2.4.20
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-source.tar.gz
PKG_SOURCE_URL:=https://github.com/OpenPrinting/cups/releases/download/v$(PKG_VERSION)/
PKG_HASH:=ab4d9cd7f3e58060091d2b24972223d6401675f11c49b65abf4f6ef31dea22ff
PKG_MAINTAINER:=Luiz Angelo Daros de Luca <luizluca@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE NOTICE
PKG_CPE_ID:=cpe:/a:openprinting:cups

include $(INCLUDE_DIR)/package.mk

define Package/libcups/Default
  URL:=https://openprinting.github.io/cups/
  SUBMENU:=Printing
endef

define Package/libcups
$(call Package/cups/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+zlib +libpthread
  TITLE:=Common UNIX Printing System - Core library
  BUILDONLY:=1
endef

define Package/libcups/description
	Common UNIX Printing System - Core library
endef

CONFIGURE_ARGS+=--with-cups-user="nobody" \
		--with-cups-group="nogroup" \
		--with-components="core" \
		--with-dnssd=no \
		--with-tls=no \
		--enable-shared \
		--disable-acl \
		--disable-dbus \
		--disable-gssapi \
		--disable-libusb \
		--disable-pam \
		UNAME="Linux"

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/cups \
		$(TARGET_CONFIGURE_OPTS) \
		DSTROOT="$(PKG_INSTALL_DIR)" \
		STRIP="/bin/true" \
		libcups.so.2 libcupsimage.so.2 install-libs install-headers
	$(INSTALL_DIR) $(PKG_INSTALL_DIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cups-config $(PKG_INSTALL_DIR)/usr/bin
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/cups-config $(1)/usr/bin/
	$(INSTALL_DIR) $(2)/bin
	$(LN) $(STAGING_DIR)/usr/bin/cups-config $(2)/bin

	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/cups $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib*/libcups*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libcups))
