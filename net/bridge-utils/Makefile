#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=bridge-utils
PKG_VERSION:=1.5
PKG_RELEASE:=5

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://git.kernel.org/pub/scm/linux/kernel/git/shemminger/bridge-utils.git
PKG_SOURCE_VERSION:=v${PKG_VERSION}
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING
PKG_FIXUP:=autoreconf

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

include $(INCLUDE_DIR)/package.mk

define Package/bridge
  SECTION:=net
  CATEGORY:=Base system
  TITLE:=Ethernet bridging configuration utility
  URL:=http://bridge.sourceforge.net/
  PKG_MAINTAINER:=Nikolay Martynov <mar.kolya@gmail.com>
endef

define Package/bridge/description
 Manage ethernet bridging: a way to connect networks together to
 form a larger network.
endef

TARGET_CFLAGS += -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE

CONFIGURE_ARGS += \
	--with-linux-headers="$(LINUX_DIR)" \

define Package/bridge/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/brctl/brctl $(1)/usr/sbin
endef

define Package/bridge/prerm
#!/bin/sh
$${IPKG_INSTROOT}/bin/busybox brctl -h 2>&1 | grep -q BusyBox && \
ln -sf ../../bin/busybox $${IPKG_INSTROOT}/usr/sbin/brctl
exit 0
endef

$(eval $(call BuildPackage,bridge))
