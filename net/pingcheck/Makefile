#
# Copyright (C) 2015 Bruno Randolf (br1@einfach.org)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pingcheck
PKG_VERSION:=2020-02-12
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MIRROR_HASH:=3890cd39add7e523ab7418faf6a7ae1a1f71d2739982e6e09aa33cc6defac8be
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/br101/pingcheck
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=520718f9377eab49888a3e38ece59f9ad94d978e

PKG_MAINTAINER:=Bruno Randolf <br1@einfach.org>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/pingcheck
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+libubus +libuci
	MAINTAINER:=Bruno Randolf <br1@einfach.org>
	TITLE:=Check Internet and interface connectivity
	URL:=https://github.com/br101/pingcheck
endef

define Package/pingcheck/description
Checks by using "ping" (ICMP echo) or by opening connections to TCP port 80
whether a configured host (normally on the internet) can be reached via a
specific interface. Then makes this information available via ubus and triggers
"online" and "offline" scripts.
endef

define Package/pingcheck/conffiles
/etc/config/pingcheck
endef

define Package/pingcheck/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/pingcheck $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./pingcheck.init $(1)/etc/init.d/pingcheck
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/pingcheck.config $(1)/etc/config/pingcheck
	$(INSTALL_DIR) $(1)/etc/pingcheck/online.d/
	$(INSTALL_DIR) $(1)/etc/pingcheck/offline.d/
	$(INSTALL_DIR) $(1)/etc/pingcheck/panic.d/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/example-script.sh $(1)/etc/pingcheck/online.d/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/example-script.sh $(1)/etc/pingcheck/offline.d/
endef

$(eval $(call BuildPackage,pingcheck))
