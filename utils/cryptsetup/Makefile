#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cryptsetup
PKG_VERSION:=2.2.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@KERNEL/linux/utils/cryptsetup/v2.2
PKG_HASH:=2af0ec9551ab9c870074cae9d3f68d82cab004f4095fa89db0e4413713424a46

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPL-2.0-or-later LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING COPYING.LGPL

include $(INCLUDE_DIR)/package.mk

define Package/cryptsetup
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Encryption
  TITLE:=Cryptsetup
  DEPENDS:=+libblkid +libuuid +libpopt +lvm2 +libdevmapper +libjson-c +@KERNEL_DIRECT_IO +kmod-crypto-user
  URL:=https://gitlab.com/cryptsetup/cryptsetup/
endef

define Package/cryptsetup/description
  Cryptsetup is utility used to conveniently setup disk encryption based on DMCrypt kernel module.
endef

CONFIGURE_ARGS += \
	--disable-cryptsetup-reencrypt \
	--disable-integritysetup \
	--disable-selinux \
	--disable-rpath \
	--disable-veritysetup \
	--disable-udev \
	--with-default-luks-format=LUKS2 \
	--with-crypto_backend=kernel

define Package/cryptsetup/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/.libs/cryptsetup $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/.libs/libcryptsetup.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,cryptsetup))
