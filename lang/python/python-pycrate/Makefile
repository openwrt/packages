# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pycrate
PKG_VERSION:=0.5.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/P1sec/pycrate/archive/refs/tags/$(PKG_VERSION).tar.gz?
PKG_HASH:=73072234359cdc11d7c6790c367d5565fdaea284a07df882b8b5295f2a4f83d1

PKG_BUILD_DIR:=$(BUILD_DIR)/pycrate-$(PKG_VERSION)

PKG_LICENSE:=LGPL-2.1
PKG_MAINTAINER:=David Bauer <mail@david-bauer.net>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pycrate
  SECTION:=lang-python
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=python3-pycrate
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
