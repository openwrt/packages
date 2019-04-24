#
# Copyright (C) 2011-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rng-tools
PKG_VERSION:=6.6
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/nhorman/rng-tools.git
PKG_SOURCE_VERSION:=4ebc21d6f387bb7b4b3f6badc429e27b21c0a6ee
PKG_MIRROR_HASH:=d942283b7482337d40a4933f7b24a5d1361518dacf9c87928f5ea06d492e95b0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.xz
PKG_LICENSE:=GPLv2
PKG_MAINTAINER:=Nathaniel Wesley Filardo <nwfilardo@gmail.com>

PKG_FIXUP:=autoreconf

PKG_BUILD_DEPENDS:=USE_UCLIBC:argp-standalone USE_MUSL:argp-standalone

include $(INCLUDE_DIR)/package.mk

define Package/rng-tools
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Daemon for adding entropy to kernel entropy pool
  URL:=https://github.com/nhorman/rng-tools
  DEPENDS:=+libsysfs
endef

define Package/rng-tools/description
Daemon for adding entropy to kernel entropy pool. By default it uses
/dev/urandom as the source but the init script can be modified
to use a hardware source like /dev/hwrng if present
endef

ifdef CONFIG_USE_UCLIBC
CONFIGURE_VARS += \
    LIBS="-largp"
endif

ifdef CONFIG_USE_MUSL
CONFIGURE_VARS += \
    LIBS="-largp"
endif

CONFIGURE_ARGS += \
	--without-libgcrypt \
	--without-nistbeacon

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
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rngtest $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rngd $(1)/sbin/
endef

$(eval $(call BuildPackage,rng-tools))
