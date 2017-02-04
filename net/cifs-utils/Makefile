#
# Copyright (C) 2007-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cifs-utils
PKG_VERSION:=6.4
PKG_RELEASE:=2

PKG_SOURCE_URL:=https://download.samba.org/pub/linux-cifs/cifs-utils/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_MD5SUM:=b7d75b67fd3987952896d27256c7293d

PKG_MAINTAINER:=Florian Fainelli <florian@openwrt.org>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

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
	--with-libcap-ng=no \
	--with-libcap=no

define Package/cifsmount/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mount.cifs $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,cifsmount))
