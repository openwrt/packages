#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=obfsproxy
PKG_VERSION:=0.2.13
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/o/obfsproxy
PKG_HASH:=1e26c2faef1cfcf856ddf60e9647058a7c78fb0d47f05b58a0f847ed7cc41a66

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python-package.mk

define Package/obfsproxy
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A pluggable transport proxy written in Python
  URL:=https://gitweb.torproject.org/pluggable-transports/obfsproxy.git/
  DEPENDS:= \
      +python-light \
      +python-crypto \
      +python-pyptlib \
      +python-setuptools \
      +python-twisted \
      +python-yaml
  VARIANT:=python
endef

define Package/obfsproxy/description
obfsproxy is a tool that attempts to circumvent censorship, by
transforming the Tor traffic between the client and the bridge. This
way, censors, who usually monitor traffic between the client and the
bridge, will see innocent-looking transformed traffic instead of the
actual Tor traffic.
endef

define Package/obfsproxy/conffiles
/etc/config/obfsproxy
endef

define PyPackage/obfsproxy/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/obfsproxy $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/obfsproxy.conf $(1)/etc/config/obfsproxy
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/obfsproxy.init $(1)/etc/init.d/obfsproxy
endef

$(eval $(call PyPackage,obfsproxy))
$(eval $(call BuildPackage,obfsproxy))
$(eval $(call BuildPackage,obfsproxy-src))
