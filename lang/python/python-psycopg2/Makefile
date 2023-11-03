#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-psycopg2
PKG_VERSION:=2.9.7
PKG_RELEASE:=1

PYPI_NAME:=psycopg2
PKG_HASH:=f00cc35bd7119f1fed17b85bd1007855194dde2cbd8de01ab8ebb17487440ad8

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>
PKG_LICENSE:=LGPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-psycopg2
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=PostgreSQL database adapter
  URL:=https://www.psycopg.org/
  DEPENDS:= \
    +python3-light \
    +python3-decimal \
    +python3-logging \
    +python3-uuid \
    +libpq
endef

define Package/python3-psycopg2/description
Psycopg is the most popular PostgreSQL adapter for the Python
programming language
endef

$(eval $(call Py3Package,python3-psycopg2))
$(eval $(call BuildPackage,python3-psycopg2))
$(eval $(call BuildPackage,python3-psycopg2-src))
