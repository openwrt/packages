#
# Copyright (C) 2019-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-sqlalchemy
PKG_VERSION:=2.0.23
PKG_RELEASE:=1

PYPI_NAME:=SQLAlchemy
PYPI_SOURCE_NAME:=sqlalchemy
PKG_HASH:=c1bda93cbbe4aa2aa0aa8655c5aeda505cd219ff3e8da91d1d329e143e4aff69

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:sqlalchemy:sqlalchemy

PKG_BUILD_DEPENDS:=python-cython/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-sqlalchemy
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Database Abstraction Library
  URL:=https://www.sqlalchemy.org
  DEPENDS:=+python3 +python3-typing-extensions
endef

define Package/python3-sqlalchemy/description
SQLAlchemy is the Python SQL toolkit and Object Relational Mapper that
gives application developers the full power and flexibility of SQL.
SQLAlchemy provides a full suite of well known enterprise-level
persistence patterns, designed for efficient and high-performing
database access, adapted into a simple and Pythonic domain language.
endef

$(eval $(call Py3Package,python3-sqlalchemy))
$(eval $(call BuildPackage,python3-sqlalchemy))
$(eval $(call BuildPackage,python3-sqlalchemy-src))
