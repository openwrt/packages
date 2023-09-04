# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=python-crcmod
PKG_VERSION:=1.7
PKG_RELEASE:=2

PYPI_NAME:=crcmod
PKG_HASH:=dc7051a0db5f2bd48665a990d3ec1cc305a466a77358ca4492826f41f283601e

PKG_LICENSE:=MIT
PKG_MAINTAINER:=David Bauer <mail@david-bauer.net>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-crcmod
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=python3-crcmod
  URL:=http://crcmod.sourceforge.net/
  DEPENDS:=+python3-light
endef

define Package/python3-crcmod/description
The software in this package is a Python module for generating
objects that compute the Cyclic Redundancy Check (CRC).
endef

$(eval $(call Py3Package,python3-crcmod))
$(eval $(call BuildPackage,python3-crcmod))
$(eval $(call BuildPackage,python3-crcmod-src))
