#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-slugify
PKG_VERSION:=3.0.1
PKG_RELEASE:=1

PKG_SOURCE:=python-slugify-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/python-slugify/
PKG_HASH:=492b27e5a12495340e50652ab4eab3a229ef7167c44b66b3a2861450e68b269a

PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-slugify
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Slugify application that handles Unicode
  URL:=https://github.com/un33k/python-slugify
  DEPENDS+= \
      +python3-light \
      +python3-text-unidecode
  VARIANT:=python3
endef

define Package/python3-slugify/description
A Python slugify application that handles unicode.
endef

$(eval $(call Py3Package,python3-slugify))
$(eval $(call BuildPackage,python3-slugify))
$(eval $(call BuildPackage,python3-slugify-src))
