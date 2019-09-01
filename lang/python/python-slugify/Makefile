#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-slugify
PKG_VERSION:=3.0.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/python-slugify/
PKG_HASH:=a9f468227cb11e20e251670d78e1b5f6b0b15dd37bbd5c9814a25a904e44ff66

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
  DEPENDS:= \
    +python3-light \
    +python3-codecs \
    +python3-setuptools \
    +python3-text-unidecode
  VARIANT:=python3
endef

define Package/python3-slugify/description
  A Python slugify application that handles unicode.
endef

$(eval $(call Py3Package,python3-slugify))
$(eval $(call BuildPackage,python3-slugify))
$(eval $(call BuildPackage,python3-slugify-src))
