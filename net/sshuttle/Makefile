#
# Copyright (C) 2022 Thomas Cujé
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sshuttle
PKG_VERSION:=1.1.1
PKG_RELEASE:=1
PKG_LICENSE:=LGPL-2.1-only

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/sshuttle/sshuttle/archive/refs/tags/v$(PKG_VERSION).tar.gz
PKG_HASH:=87b6343da4b7ea164cc1638a3ff25c41cf9dbc70bbc84bc4df8c41f963a4b0b9

PKG_MAINTAINER:=Thomas Cujé <dev.cuje@freenet.de>

include $(INCLUDE_DIR)/package.mk

define Package/sshuttle
  SUBMENU:=SSH
  SECTION:=net
  CATEGORY:=Network
  TITLE:=sshuttle: where transparent proxy meets VPN meets ssh
  DEPENDS:=+python3 +python3-pip +iptables-mod-extra +iptables-mod-nat-extra +iptables-mod-ipopt
  PKGARCH:=all
endef

define Package/sshuttle/description
  Transparent proxy server that works as a poor man's VPN. Forwards over ssh. Doesn't require admin. Works with Linux and MacOS. Supports DNS tunneling.
endef

define Package/sshuttle/conffiles
/etc/config/sshuttle
endef

define Build/Compile
endef

define Package/sshuttle/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/sshuttle.init $(1)/etc/init.d/sshuttle
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/sshuttle.config $(1)/etc/config/sshuttle
endef

define Package/sshuttle/postinst
#!/bin/sh
/usr/bin/pip3 install sshuttle==$(PKG_VERSION)
endef

$(eval $(call BuildPackage,sshuttle))
