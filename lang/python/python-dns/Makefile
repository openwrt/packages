#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-dns
PKG_VERSION:=1.16.0
PKG_RELEASE:=1

PKG_SOURCE:=dnspython-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.dnspython.org/kits/1.16.0/
PKG_HASH:=4bf5c5c12a4478ee7860ab176659cf64c4899ee76752d826b082f8af723c5cf9

PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_CPE_ID:=cpe:/a:debian:python-dns

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-dnspython-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-dns/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=dnspython
  URL:=http://www.dnspython.org/
endef

define Package/python-dns
$(call Package/python-dns/Default)
  DEPENDS:=+PACKAGE_python-dns:python
  VARIANT:=python
endef

define Package/python-dns/description
 dnspython is a DNS toolkit for Python. It supports almost all record types. It can be used for queries, zone transfers, and dynamic updates. It supports TSIG authenticated messages and EDNS0.
endef

define Package/python3-dns
$(call Package/python-dns/Default)
  DEPENDS:=+PACKAGE_python3-dns:python3
  VARIANT:=python3
endef

define Package/python3-dns/description
$(call Package/python-dns/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-dns))
$(eval $(call BuildPackage,python-dns))
$(eval $(call BuildPackage,python-dns-src))
$(eval $(call Py3Package,python3-dns))
$(eval $(call BuildPackage,python3-dns))
$(eval $(call BuildPackage,python3-dns-src))
