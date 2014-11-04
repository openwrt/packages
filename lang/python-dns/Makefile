#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dnspython
PKG_RELEASE:=1
PKG_VERSION:=1.12.0
PKG_SOURCE_URL:=http://www.dnspython.org/kits/$(PKG_VERSION)
PKG_MD5SUM:=3f2601ef3c8b77fc6d21a9c77a81efeb
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MAINTAINER:=Denis Shulyaka <Shulyaka@gmail.com>
PKG_LICENSE:=ISC
PKG_LICENSE_FILE:=LICENSE

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-dns
	SECTION:=language-python
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=dnspython
	URL:=http://www.dnspython.org/
	DEPENDS:=+python-mini
endef

define Package/python-dns/description
 dnspython is a DNS toolkit for Python. It supports almost all record types. It can be used for queries, zone transfers, and dynamic updates. It supports TSIG authenticated messages and EDNS0.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/python-dns/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/dns/* \
		$(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,python-dns))
