#
# Copyright (C) 2010 segal.di.ubi.pt
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=watchcat
PKG_VERSION:=1
PKG_RELEASE:=5

PKG_MAINTAINER:=Roger D <rogerdammit@gmail.com>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/watchcat
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Enable the configuration of programed reboots
endef

define Package/watchcat/description
Allows to configure a periodically reboot, or after loosing internet connectivity. Configured trough UCI /etc/config/system.
endef

define Package/watchcat/conffiles
/etc/config/system
endef

define Build/Compile
endef

define Package/watchcat/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/initd_watchcat $(1)/etc/init.d/watchcat
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/watchcat.sh $(1)/usr/bin/watchcat.sh
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/uci_defaults_watchcat $(1)/etc/uci-defaults/50-watchcat
endef

$(eval $(call BuildPackage,watchcat))
