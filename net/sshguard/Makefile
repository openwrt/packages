# 
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sshguard
PKG_VERSION:=1.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/$(PKG_NAME)
PKG_MD5SUM:=11b9f47f9051e25bdfe84a365c961ec1

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/sshguard
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=SSH
  TITLE:=sshguard block the ssh attacker with a firewall rule
  URL:=http://sshguard.sourceforge.net/
  DEPENDS:= +libpthread
endef

define Package/tinc/description
  Sshguard monitors servers from their logging activity.
  When logs convey that someone is doing a Bad Thing,
  sshguard reacts by blocking he/she/it for a bit.
  Sshguard has a touchy personality:
  when a naughty tyke insists disturbing your host, it reacts firmer and firmer.
endef

#CONFIGURE_PATH = ./src
CONFIGURE_ARGS += --with-firewall=iptables

MAKE_PATH = ./src
TARGET_CFLAGS += -include endian.h

define Package/sshguard/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/$(PKG_NAME) $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) files/$(PKG_NAME).init $(1)/etc/init.d/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/$(PKG_NAME).config $(1)/etc/config/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_CONF) files/$(PKG_NAME).default $(1)/etc/uci-defaults/15_$(PKG_NAME)-enable-logging
endef

define Package/sshguard/conffiles
/etc/config/$(PKG_NAME)
endef

$(eval $(call BuildPackage,sshguard))
