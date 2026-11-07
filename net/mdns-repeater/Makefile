#
# This is free software, licensed under the GNU General Public License v2.
# See LICENSE.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mdns-repeater
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/geekman/mdns-repeater.git
PKG_SOURCE_PROTO=git
PKG_SOURCE_DATE:=2026-07-16
PKG_SOURCE_VERSION:=488feaf7da1a4b54de120ea00f0f3eb629cdfd8e
PKG_MIRROR_HASH:=9fd326c4d7874ff5c7145c9bb9c11408dd31cda568aafe7d134a12cb3579bac5

PKG_MAINTAINER:=Alexander Koenig <alex@lisas.de>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE.txt

include $(INCLUDE_DIR)/package.mk

define Package/mdns-repeater
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Multicast DNS repeater for Linux
  SUBMENU:=IP Addresses and Names
  URL:=https://github.com/geekman/mdns-repeater
endef

MAKE_FLAGS += HGVERSION='$(VERSION)'

define Package/mdns-repeater/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mdns-repeater $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mdns-repeater.init $(1)/etc/init.d/mdns-repeater

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/mdns_repeater.conf $(1)/etc/config/mdns_repeater
endef

$(eval $(call BuildPackage,mdns-repeater))
