#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=chrony
PKG_VERSION:=1.26
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:= ftp://download.tuxfamily.org/projects/chrony/ \
	http://download.tuxfamily.org/chrony/
PKG_MD5SUM:=ad6dd619ff1986e4ff780363c64e2246

include $(INCLUDE_DIR)/package.mk

define Package/chrony
  SUBMENU:=Time Synchronization
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libreadline +libncurses @!TARGET_avr32 @!powerpc
  TITLE:=NTP client/server for on-demand connections
  URL:=http://chrony.sunsite.dk/
endef

define Package/chrony/description
	A NTP implementation that has been specifically written to work
	well in the case of an intermittent (e.g. dial-on-demand)
	connection to the network where your NTP servers are.
endef

define Package/chrony/conffiles
/etc/chrony/chrony.conf
endef

define Build/Configure
	$(call Build/Configure/Default, \
			--target=$(GNU_TARGET_NAME) \
			--prefix=/usr \
			--with-readline-includes=$(STAGING_DIR)/usr/include \
			--with-readline-library=$(STAGING_DIR)/usr/lib \
			--disable-linuxcaps \
	)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		prefix="$(PKG_INSTALL_DIR)/usr"
endef

define Package/chrony/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/chronyd $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/chronyc $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/chrony
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/ntpd.hotplug $(1)/etc/hotplug.d/iface/20-ntpd
	$(INSTALL_BIN) ./files/ntpd.init $(1)/etc/init.d/ntpd
	$(INSTALL_CONF) ./files/ntpd.config $(1)/etc/config/ntpd
	$(INSTALL_CONF) ./files/chrony.conf $(1)/etc/chrony/chrony.conf
	$(INSTALL_CONF) ./files/chrony.keys $(1)/etc/chrony/chrony.keys
endef

$(eval $(call BuildPackage,chrony))
