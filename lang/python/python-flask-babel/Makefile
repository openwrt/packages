#
# Copyright (C) 2019-2020 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-flask-babel
PKG_VERSION:=3.1.0
PKG_RELEASE:=1

PYPI_NAME:=flask-babel
PYPI_SOURCE_NAME:=flask_babel
PKG_HASH:=be015772c5d7f046f3b99c508dcf618636eb93d21b713b356db79f3e79f69f39

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-poetry-core/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-flask-babel
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=i18n/l10n support for Flask applications
  URL:=https://github.com/python-babel/flask-babel
  DEPENDS:= \
    +python3-light \
    +python3-flask \
    +python3-babel \
    +python3-jinja2 \
    +python3-pytz
endef

define Package/python3-flask-babel/description
  Implements i18n and l10n support for Flask.
endef

$(eval $(call Py3Package,python3-flask-babel))
$(eval $(call BuildPackage,python3-flask-babel))
$(eval $(call BuildPackage,python3-flask-babel-src))
