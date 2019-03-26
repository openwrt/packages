#
# Copyright (C) 2007-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cifs-utils
PKG_VERSION:=6.8
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://download.samba.org/pub/linux-cifs/cifs-utils/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=e7d1f6050c43f21f82cd77e288eb756755effd22f0c310fc2c525df9d41dff79

PKG_MAINTAINER:=Florian Fainelli <florian@openwrt.org>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=libtool

include $(INCLUDE_DIR)/package.mk

define Package/cifsmount
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+kmod-fs-cifs
  TITLE:=CIFS mount utilities
  URL:=http://wiki.samba.org/index.php/LinuxCIFS_utils
endef

TARGET_CFLAGS += -Wno-error

CONFIGURE_ARGS += \
	--exec-prefix=/usr \
	--prefix=/ \
	--with-libcap=no \
	--disable-cifsupcall \
	--disable-cifscreds \
	--disable-cifsidmap \
	--disable-cifsacl \
	--disable-pam \
	--disable-systemd \
	--disable-man

define Package/cifsmount/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mount.cifs $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,cifsmount))
