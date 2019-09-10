#
# Copyright (C) 2015 Jeff Waugh
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=kmod
PKG_VERSION:=20
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@KERNEL/linux/utils/kernel/kmod/
PKG_HASH:=89c1a1a2193c31f9ebe582640bfa2bd401341dc24119f5a7f702588116fadaa0
PKG_MAINTAINER:=Jeff Waugh <jdub@bethesignal.org>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING
PKG_FIXUP:=autoreconf

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += --with-zlib

define Package/kmod/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Linux kernel module handling
  URL:=https://www.kernel.org/pub/linux/utils/kernel/kmod/
  DEPENDS:=+zlib
endef


define Package/kmod
$(call Package/kmod/Default)
  TITLE+= (tools)
endef

define Package/kmod/description
Linux kernel module handling
 kmod is a set of tools to handle common tasks with Linux kernel modules like
 insert, remove, list, check properties, resolve dependencies and aliases.
endef

LEGACY_BINARIES:= \
	depmod \
	insmod \
	lsmod \
	modinfo \
	modprobe \
	rmmod

define Package/kmod/install
	$(INSTALL_DIR) $(1)/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/kmod $(1)/sbin

	for b in $(LEGACY_BINARIES); do \
		ln -sf kmod $(1)/sbin/$$$$b ; \
	done
endef


define Package/libkmod
$(call Package/kmod/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= (library)
endef

define Package/libkmod/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libkmod.so.* $(1)/usr/lib/
endef


define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include $(1)/usr/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libkmod.{so*,la} $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libkmod.pc $(1)/usr/lib/pkgconfig/
endef


$(eval $(call BuildPackage,kmod))
$(eval $(call BuildPackage,libkmod))
