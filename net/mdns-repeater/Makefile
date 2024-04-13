#
# This is free software, licensed under the GNU General Public License v2.
# See LICENSE.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mdns-repeater
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/kennylevinsen/mdns-repeater.git
PKG_SOURCE_PROTO=git
PKG_SOURCE_DATE:=2020-05-03
PKG_SOURCE_VERSION:=921d8850e988d0bd8d60899d933c4ad3094d73ca
PKG_MIRROR_HASH:=19997460a7eb9816b0c13328ce02331fac532dab549d602e35d671d5f481bfee

PKG_MAINTAINER:=Alexander Koenig <alex@lisas.de>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE.txt

include $(INCLUDE_DIR)/package.mk

define Package/mdns-repeater
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Multicast DNS repeater for Linux
  URL:=https://github.com/kennylevinsen/mdns-repeater
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
