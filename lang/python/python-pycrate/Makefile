# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pycrate
PKG_VERSION:=0.7.11
PKG_RELEASE:=1

PYPI_NAME:=pycrate
PKG_HASH:=23dc1c19b148a17637fea73166b801c767ae738cc4cb3d8b1f74a29e469d7c02

PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=license.txt
PKG_MAINTAINER:=David Bauer <mail@david-bauer.net>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pycrate
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=A software suite to handle various data formats
  URL:=https://github.com/P1sec/pycrate
  DEPENDS:=+python3-light
endef

define Package/python3-pycrate/description
Provides a runtime for encoding and decoding data structures, including CSN.1
and ASN.1. Additionally, it features a 3G and LTE mobile core network.
endef

$(eval $(call Py3Package,python3-pycrate))
$(eval $(call BuildPackage,python3-pycrate))
$(eval $(call BuildPackage,python3-pycrate-src))
