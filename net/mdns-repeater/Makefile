#
# This is free software, licensed under the GNU General Public License v2.
# See LICENSE.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mdns-repeater
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/geekman/mdns-repeater.git
PKG_SOURCE_PROTO=git
PKG_SOURCE_DATE:=2023-12-16
PKG_SOURCE_VERSION:=f714ec4d8a0eee248ead29c2ae1bb37f124a568f
PKG_MIRROR_HASH:=ccc76784483550bcbe3b65f2efee39372516c2cf5d18ef58636cf2661139c4b8

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

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include

define Build/Compile
	CFLAGS="$(TARGET_CFLAGS)" CPPFLAGS="$(TARGET_CPPFLAGS)" $(MAKE) -C $(PKG_BUILD_DIR) $(TARGET_CONFIGURE_OPTS)
endef

define Package/mdns-repeater/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mdns-repeater $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mdns-repeater.init $(1)/etc/init.d/mdns-repeater

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/mdns_repeater.conf $(1)/etc/config/mdns_repeater
endef

$(eval $(call BuildPackage,mdns-repeater))
