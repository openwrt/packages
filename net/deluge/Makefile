#
# Copyright (C) 2008-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=deluge
PKG_VERSION:=1.3.15
PKG_RELEASE:=1
PKG_MAINTAINER:= Sergey Pushilin <pushilin@gmail.com>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://download.deluge-torrent.org/source
PKG_HASH:=a96405140e3cbc569e6e056165e289a5e9ec66e036c327f3912c73d049ccf92c


include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python-package.mk

define Package/deluge
	SUBMENU:=BitTorrent
	SECTION:=net
	CATEGORY:=Network
	TITLE:=A lightweight BitTorrent client
	URL:=https://deluge-torrent.org
	DEPENDS:=+python +rblibtorrent +python-chardet +python-pyxdg +python-twisted +python-pyopenssl +python-setuptools +python-service-identity
	VARIANT:=python
endef

define Package/deluge/description
BitTorrent client with a client/server model.
endef

define Package/deluge/conffiles
/etc/config/deluge
endef

define PyPackage/deluge/filespec
  +|$(PYTHON_PKG_DIR)
  -|$(PYTHON_PKG_DIR)/deluge/ui/gtkui
  -|$(PYTHON_PKG_DIR)/deluge/ui/web
endef

define PyPackage/deluge/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) \
	    $(PKG_INSTALL_DIR)/usr/bin/* \
	    $(1)/usr/bin/
	rm -rf $(1)/usr/bin/deluge-gtk
	rm -rf $(1)/usr/bin/deluge-web

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/deluge.config $(1)/etc/config/deluge

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/deluge.init $(1)/etc/init.d/deluge
endef

$(eval $(call PyPackage,deluge))
$(eval $(call BuildPackage,deluge))
