#
# Copyright (C) 2007-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cifs-utils
PKG_VERSION:=6.9
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://download.samba.org/pub/linux-cifs/cifs-utils/
PKG_HASH:=18d8f1bf92c13c4d611502dbd6759e3a766ddc8467ec8a2eda3f589e40b9ac9c

PKG_MAINTAINER:=Florian Fainelli <florian@openwrt.org>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:debian:cifs-utils

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/cifsmount
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+kmod-fs-cifs
  TITLE:=CIFS mount
  URL:=https://wiki.samba.org/index.php/LinuxCIFS_utils
endef

define Package/smbinfo
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+kmod-fs-cifs
  TITLE:=SMB info
  URL:=https://wiki.samba.org/index.php/LinuxCIFS_utils
endef

CONFIGURE_ARGS += \
	--disable-cifsupcall \
	--disable-cifscreds \
	--disable-cifsidmap \
	--disable-cifsacl \
	--disable-pam \
	--disable-pie \
	--disable-relro \
	--disable-systemd \
	--disable-man \
	--without-libcap

TARGET_CFLAGS += $(FPIC) -ffunction-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/include/cifsidmap.h $(1)/usr/include/
endef

define Package/cifsmount/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/sbin/mount.cifs $(1)/usr/sbin/
endef

define Package/smbinfo/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/smbinfo $(1)/usr/bin/
endef

$(eval $(call BuildPackage,cifsmount))
$(eval $(call BuildPackage,smbinfo))
