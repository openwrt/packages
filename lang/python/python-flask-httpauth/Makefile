#
# Copyright (C) 2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-flask-httpauth
PKG_VERSION:=4.8.1
PKG_RELEASE:=1

PYPI_NAME:=flask-httpauth
PYPI_SOURCE_NAME:=flask_httpauth
PKG_HASH:=88499b22f1353893743c3cd68f2ca561c4ad9ef75cd6bcc7f621161cd0e80744

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-flask-httpauth
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=HTTP authentication for Flask routes
  URL:=https://github.com/miguelgrinberg/flask-httpauth
  DEPENDS:= \
	+python3-light \
	+python3-flask
endef

define Package/python3-flask-httpauth/description
  Flask-HTTPAuth is a Flask extension that simplifies the
  use of HTTP authentication with Flask routes
endef

$(eval $(call Py3Package,python3-flask-httpauth))
$(eval $(call BuildPackage,python3-flask-httpauth))
$(eval $(call BuildPackage,python3-flask-httpauth-src))
