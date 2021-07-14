#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=muninlite
PKG_VERSION:=2.1.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/munin-monitoring/$(PKG_NAME)/releases/download/$(PKG_VERSION)/
PKG_HASH:=5a49da30944f3b85a0030b661a27e84c06c7f640050802e799304b11cc635ffc

PKG_MAINTAINER:=Jonathan McCrohan <jmccrohan@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/muninlite
  SECTION:=admin
  CATEGORY:=Administration
  DEPENDS:=+xinetd
  TITLE:=Munin node implemented in shell
  URL:=https://github.com/munin-monitoring/muninlite
endef

define Package/muninlite/Default/description
	Munin node implemented in shell.
	Munin is a monitoring system for Unix networks.
endef

define Package/muninlite/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/muninlite $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/xinetd.d
	$(INSTALL_DATA) ./files/etc/xinetd.d/muninlite $(1)/etc/xinetd.d/
	$(INSTALL_DIR) $(1)/etc/munin/plugins
endef

define Package/muninlite/conffiles
/etc/xinetd.d/muninlite
endef

$(eval $(call BuildPackage,muninlite))
