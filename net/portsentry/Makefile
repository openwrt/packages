#
# Copyright (C) 2007-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=portsentry
PKG_VERSION:=1.2
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-1.2.tar.gz
PKG_SOURCE_URL:=@SF/sentrytools
PKG_MD5SUM:=3ebd3618ba9abfea2525e236bd44cebd

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_beta

include $(INCLUDE_DIR)/package.mk

define Package/portsentry
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Firewall
  TITLE:=Portscan protection utility
  URL:=http://sourceforge.net/projects/sentrytools
endef

define Package/portsentry/conffiles
/etc/portsentry.conf
endef

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS) -DNODAEMON" \
	linux \

define Package/portsentry/install	
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/portsentry $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/portsentry.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/portsentry.init $(1)/etc/init.d/portsentry
	$(SED) 's|^\(.*_FILE\)="/usr/local/psionic/\(portsentry/.*\)"|\1="/var/run/\2"|g' \
	     $(1)/etc/portsentry.conf
endef

$(eval $(call BuildPackage,portsentry))
