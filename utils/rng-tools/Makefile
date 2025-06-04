#
# Copyright (C) 2011-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rng-tools
PKG_VERSION:=6.17
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/nhorman/rng-tools/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=4aa50994232da74499b60b3ebf79118e30a1943be375b7d931dcf18df5442fd3

PKG_MAINTAINER:=Nathaniel Wesley Filardo <nwfilardo@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:rng-tools_project:rng-tools

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=!USE_GLIBC:argp-standalone

include $(INCLUDE_DIR)/package.mk

define Package/rng-tools
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Daemon for adding entropy to kernel entropy pool
  URL:=https://github.com/nhorman/rng-tools
  DEPENDS:=+libopenssl +libcurl +libcap +jansson
endef

define Package/rng-tools/description
  Daemon for adding entropy to kernel entropy pool. By default it uses
  /dev/urandom as the source but the init script can be modified
  to use a hardware source like /dev/hwrng if present
endef

CONFIGURE_ARGS += \
	--without-nistbeacon \
	--without-pkcs11 \
	--without-rtlsdr

ifndef CONFIG_USE_GLIBC
	CONFIGURE_VARS += LIBS="-largp"
endif

define Build/Prepare
	$(call Build/Prepare/Default)
	(cd $(PKG_BUILD_DIR); ln -s README.md README)
endef

define Package/rng-tools/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/rngd.init $(1)/etc/init.d/rngd
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/rngd.uci_defaults $(1)/etc/uci-defaults/rngd
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rngtest $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/rngd $(1)/sbin/
endef

$(eval $(call BuildPackage,rng-tools))
