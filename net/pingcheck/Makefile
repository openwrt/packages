#
# Copyright (C) 2015 Bruno Randolf (br1@einfach.org)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pingcheck
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/br101/pingcheck.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=0f099998782f550e2abebdc65bcc3e969b798769

PKG_MAINTAINER:=Bruno Randolf <br1@einfach.org>
PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/pingcheck
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+libubus +libuci
	MAINTAINER:=Bruno Randolf <br1@einfach.org>
	TITLE:=Check Internet and interface connectivity
endef

define Package/pingcheck/description
Checks by using "ping" (ICMP echo) wether a configured host (normally on the
internet) can be reached via a specific interface. Then makes this information
available via ubus and triggers "online" and "offline" scripts.
endef

define Package/pingcheck/conffiles
/etc/config/pingcheck
endef

define Package/pingcheck/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pingcheck $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./pingcheck.init $(1)/etc/init.d/pingcheck
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/pingcheck.config $(1)/etc/config/pingcheck
endef

$(eval $(call BuildPackage,pingcheck))
