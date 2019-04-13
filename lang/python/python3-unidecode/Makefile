#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python3-unidecode
PKG_VERSION:=1.0.23
PKG_RELEASE:=1

PKG_SOURCE:=Unidecode-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/u/unidecode/
PKG_HASH:=8b85354be8fd0c0e10adbf0675f6dc2310e56fda43fa8fe049123b6c475e52fb

PKG_BUILD_DIR:=$(BUILD_DIR)/Unidecode-$(PKG_VERSION)

PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-unidecode
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=ASCII transliterations of Unicode text
  URL:=https://github.com/avian2/unidecode
  DEPENDS:=+python3-light
  VARIANT:=python3
endef

define Package/python-unidecode/description
Unidecode, lossy ASCII transliterations of Unicode text
endef

$(eval $(call Py3Package,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-src))
