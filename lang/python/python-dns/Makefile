#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-dns
PKG_RELEASE:=2
PKG_VERSION:=1.15.0
PKG_SOURCE_URL:=http://www.dnspython.org/kits/$(PKG_VERSION)
PKG_HASH:=11598ae5735746e63921f8eebdfdee4a2e7d0ba842ebd57ba02682d4aed8244b
PKG_SOURCE:=dnspython-$(PKG_VERSION).tar.gz
PKG_MAINTAINER:=Denis Shulyaka <Shulyaka@gmail.com>
PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=LICENSE
PKG_BUILD_DIR:=$(BUILD_DIR)/dnspython-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/python-dns
	SECTION:=language-python
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=dnspython
	URL:=http://www.dnspython.org/
	DEPENDS:=+python
endef

define Package/python-dns/description
 dnspython is a DNS toolkit for Python. It supports almost all record types. It can be used for queries, zone transfers, and dynamic updates. It supports TSIG authenticated messages and EDNS0.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,\
		install --prefix=/usr --root="$(PKG_INSTALL_DIR)" \
	)
endef

$(eval $(call PyPackage,python-dns))
$(eval $(call BuildPackage,python-dns))
