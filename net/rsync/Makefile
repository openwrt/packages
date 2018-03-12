#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rsync
PKG_VERSION:=3.1.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://download.samba.org/pub/rsync/src
PKG_HASH:=55cc554efec5fdaad70de921cd5a5eeb6c29a95524c715f3bbf849235b0800c0
PKG_MAINTAINER:=Maxim Storchak <m.storchak@gmail.com>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/rsync
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=File Transfer
  TITLE:=Fast remote file copy program (like rcp)
  DEPENDS:=+libpopt +RSYNC_xattr:libattr +RSYNC_acl:libacl +RSYNC_zlib:zlib
  URL:=http://rsync.samba.org/
  MENU:=1
endef

define Package/rsync/config
	source "$(SOURCE)/Config.in"
endef

CONFIGURE_ARGS += \
	--with-included-popt=no \
	--disable-debug \
	--disable-locale \

ifeq ($(CONFIG_RSYNC_xattr),y)
	CONFIGURE_ARGS+= --enable-xattr-support
else
	CONFIGURE_ARGS+= --disable-xattr-support
endif

ifeq ($(CONFIG_RSYNC_acl),y)
	CONFIGURE_ARGS+= --enable-acl-support
else
	CONFIGURE_ARGS+= --disable-acl-support
endif

ifeq ($(CONFIG_RSYNC_zlib),y)
	CONFIGURE_ARGS+= --with-included-zlib=no
else
	CONFIGURE_ARGS+= --with-included-zlib=yes
endif

define Package/rsyncd
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=File Transfer
  TITLE:=Rsync daemon
  DEPENDS:=+rsync
  URL:=http://rsync.samba.org/
endef

define Package/rsync/description
 rsync is a program that allows files to be copied to and from remote machines
 in much the same way as rcp. It has many more options than rcp, and uses the
 rsync remote-update protocol to greatly speed up file transfers when the
 destination file already exists.

 The rsync remote-update protocol allows rsync to transfer just the differences
 between two sets of files across the network link.
endef

define Package/rsync/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(1)/usr/bin/
endef

define Package/rsyncd/description
 rsyncd is a configuration file and initscript to utilize rsync as a daemon. It
 uses the same binary as rsync.
endef

define Package/rsyncd/conffiles
/etc/rsyncd.conf
endef

define Package/rsyncd/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) ./files/rsyncd.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/rsyncd.init $(1)/etc/init.d/rsyncd
endef

$(eval $(call BuildPackage,rsync))
$(eval $(call BuildPackage,rsyncd))
