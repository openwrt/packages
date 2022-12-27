#
# Copyright (C) 2022 Thomas Cujé
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sshuttle
PKG_VERSION:=1.1.1
PKG_RELEASE:=$(AUTORELEASE)

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=f5a3ed1e5ab1213c7a6df860af41f1a903ab2cafbfef71f371acdcff21e69ee6

PKG_MAINTAINER:=Thomas Cujé <dev.cuje@freenet.de>
PKG_LICENSE:=LGPL-2.1-only

include ../../lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

define Package/sshuttle
  SUBMENU:=SSH
  SECTION:=net
  CATEGORY:=Network
  TITLE:=sshuttle: where transparent proxy meets VPN meets ssh
  URL:=https://github.com/sshuttle/sshuttle
  DEPENDS:= \
  +python3-light \
  +python3-ctypes \
  +python3-urllib \
  +iptables-mod-extra \
  +iptables-mod-nat-extra \
  +iptables-mod-ipopt
endef

define Package/sshuttle/description
  Transparent proxy server that works as a poor man's VPN. Forwards over ssh. Doesn't require admin. Works with Linux and MacOS. Supports DNS tunneling.
endef

define Package/sshuttle/conffiles
/etc/config/sshuttle
endef

define Package/sshuttle/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/sshuttle.init $(1)/etc/init.d/sshuttle
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/sshuttle.config $(1)/etc/config/sshuttle
endef

$(eval $(call Py3Package,sshuttle))
$(eval $(call BuildPackage,sshuttle))
$(eval $(call BuildPackage,sshuttle-src))
