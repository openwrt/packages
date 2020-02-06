#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=bridge-utils
PKG_VERSION:=1.6
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@KERNEL/linux/utils/net/$(PKG_NAME)
PKG_HASH:=cc67efb5d5fb8928a6569b3fade2b4042ec17da04678dab127d96b46489e26c8
PKG_MAINTAINER:=Nikolay Martynov <mar.kolya@gmail.com>

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/bridge
  SECTION:=net
  CATEGORY:=Base system
  TITLE:=Ethernet bridging configuration utility
  URL:=http://www.linuxfromscratch.org/blfs/view/svn/basicnet/bridge-utils.html
  ALTERNATIVES:=300:/usr/sbin/brctl:/usr/libexec/bridge-utils-brctl
endef

define Package/bridge/description
 Manage ethernet bridging: a way to connect networks together to
 form a larger network.
endef

TARGET_CFLAGS += -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE

CONFIGURE_ARGS += \
	--with-linux-headers="$(LINUX_DIR)" \

define Package/bridge/install
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/brctl/brctl $(1)/usr/libexec/bridge-utils-brctl
endef

$(eval $(call BuildPackage,bridge))
