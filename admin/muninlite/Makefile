#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=muninlite
PKG_VERSION:=1.0.4
PKG_RELEASE:=10

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/$(PKG_NAME)
PKG_HASH:=736482dd6d6849d014d975b1f5794f20dda6e123dbba2d8c2f169c8e787e6f7e
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/muninlite
  SECTION:=admin
  CATEGORY:=Administration
  DEPENDS:=+xinetd
  TITLE:=Munin node implemented in shell
  URL:=http://sourceforge.net/projects/muninlite/
  PKG_MAINTAINER:=Jonathan McCrohan <jmccrohan@gmail.com>
endef

define Package/muninlite/Default/description
	Munin node implemented in shell.
	Munin is a monitoring system for Unix networks.
endef

define Package/muninlite/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/munin-node $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/xinetd.d
	$(INSTALL_DATA) ./files/etc/xinetd.d/munin $(1)/etc/xinetd.d/
endef

define Package/muninlite/conffiles
/etc/xinetd.d/munin
endef

define Build/Configure
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)
endef

$(eval $(call BuildPackage,muninlite))
