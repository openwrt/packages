#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cmdpad
PKG_VERSION:=0.0.3
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=@SF/cmdpad
PKG_MD5SUM:=6633b2354b7f23f9cd8e2bfb6e735965

PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=doc/COPYING

include $(INCLUDE_DIR)/package.mk

define Package/cmdpad
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=execute commands when a key is pressed, released or hold down
  URL:=http://cmdpad.sourceforge.net/index.php
endef

CONFIGURE_ARGS += \
	--enable-static \
	--enable-shared

define Package/cmdpad/description
	cmdpad - execute commands when a key is pressed, released or hold down.
	Should be started from /etc/rc or /etc/rc.local. To run it as daemon you
	need to start it with '&'. All logs are printed to standard out and standard
	error (to write the log to disk use cmdpad > /var/log/cmdpad). Cmdpad
	searches for /etc/cmdpad.conf and load the key bindings. Then wait for
	key event and check each command to see if it should be run.
endef

MAKE_FLAGS += \
	$(TARGET_CONFIGURE_OPTS) \
	$(1)

define Package/cmdpad/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/cmdpad $(1)/usr/sbin/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/src/cmdpad.conf $(1)/etc/
	$(INSTALL_BIN) ./files/cmdpad.init $(1)/etc/init.d/cmdpad
endef

define Package/cmdpad/conffiles
/etc/cmdpad.conf
endef

$(eval $(call BuildPackage,cmdpad))
