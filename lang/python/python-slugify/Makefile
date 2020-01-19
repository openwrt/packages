#
# Copyright (C) 2019-2020 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-slugify
PKG_VERSION:=4.0.0
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=a8fc3433821140e8f409a9831d13ae5deccd0b033d4744d94b31fea141bdd84c

PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
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
