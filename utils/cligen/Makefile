#
# Copyright (C) 2020-2023 Olof Hagsand and Rubicon Communications, LLC(Netgate)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=cligen
PKG_VERSION:=7.6.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/clicon/$(PKG_NAME)/tar.gz/$(PKG_VERSION)?
PKG_HASH:=547e9df4017fa7bc1fd88abbd6680ab2383b8d14b272ee04cb950ad5da04889d

PKG_MAINTAINER:=Olof Hagsand <olof@hagsand.se>, Philip Prindeville <philipp@redfish-solutions.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE.md

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/cligen
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=https://www.cligen.se
  TITLE:=CLIgen is a Command-Line Interface generator
  DEPENDS:=libxml2
endef

define Package/cligen/description
  CLIgen provides dynamic CLI interpretation from grammar files
  handled at run-time.
endef

CONFIGURE_ARGS+= \
	--exec-prefix=/usr

CONFIGURE_ARGS:=$(filter-out --disable-dependency-tracking,$(CONFIGURE_ARGS))

INSTALLFLAGS:=-s --strip-program=$(TARGET_CROSS)strip

CONFIGURE_VARS+= \
	INSTALLFLAGS="$(INSTALLFLAGS)"

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/cligen $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcligen.so* $(1)/usr/lib/
endef

define Package/cligen/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcligen.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,cligen))
