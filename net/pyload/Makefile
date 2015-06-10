#
# Copyright (C) 2011-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pyload
PKG_VERSION:=0.4.9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-src-v$(PKG_VERSION).zip
PKG_SOURCE_URL:=http://download.pyload.org/
PKG_MD5SUM:=28876150af22999b6f539c8579d3b415
PKG_MAINTAINER:=Oliver Ertl <oliver-ertl@t-online.de>

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/

include $(INCLUDE_DIR)/package.mk

PKG_UNPACK=unzip -d $(PKG_BUILD_DIR) $(DL_DIR)/$(PKG_SOURCE)

define Package/pyload
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+python +pyopenssl +python-curl +python-crypto \
	+python-expat +python-imaging-library +python-sqlite3 +js \
	+tesseract +unrar
  TITLE:=A fast, lightweight and full featured download manager
  URL:=http://pyload.org
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/pyload/install
	$(INSTALL_DIR) $(1)/usr/share/python
	$(CP) $(PKG_BUILD_DIR)/pyload $(1)/usr/share/python/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/pyload.init $(1)/etc/init.d/pyload
	$(INSTALL_DIR) $(1)/usr/bin
	$(LN) ../share/python/pyload/pyLoadCore.py $(1)/usr/bin/pyload
endef

$(eval $(call BuildPackage,pyload))
