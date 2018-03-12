#
# Copyright (C) 2017 Andrew McConachie
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=danish
PKG_VERSION:=0.1
PKG_RELEASE:=1
PKG_MAINTAINER:=Andrew McConachie <andrew@depht.com>
PKG_LICENSE:=GPL-3.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/smutt/danish.git
PKG_SOURCE_VERSION:=f726656a4e37c46c037f61334ac48b35b7de25be
PKG_MIRROR_HASH:=cb0b4bb7a210091d807ee8e4a2876865f32a9bf195836eb2e1edf6c5975d1130
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python-package.mk

define Package/danish
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=IP Addresses and Names
	TITLE:=A middle box implementation of RFC 6698 for HTTPS.
	URL:=https://github.com/smutt/danish
	DEPENDS:=+python +python-dns +python-pcapy +python-dpkt +kmod-ipt-filter +iptables-mod-filter +dnsmasq-full
endef

define Package/danish/description
  Danish is an experiment in middle-box DANE (RFC 6698) for HTTPS.
  https://www.middlebox-dane.org/
endef

define Build/Compile
	$(call Build/Compile/PyMod,,\
		install --prefix=/usr --root="$(PKG_INSTALL_DIR)", \
	)
endef

define Package/danish/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/danish.py $(1)/usr/sbin/danish
	$(INSTALL_DIR) $(1)/etc/config
	$(CP) $(PKG_BUILD_DIR)/danish.conf $(1)/etc/config/danish 
	$(INSTALL_DIR) $(1)/etc/init.d
	$(CP) $(PKG_BUILD_DIR)/danish.init $(1)/etc/init.d/danish
endef

$(eval $(call BuildPackage,danish))
