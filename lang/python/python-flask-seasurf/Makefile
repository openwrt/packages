#
# Copyright (C) 2019-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-flask-seasurf
PKG_VERSION:=1.1.1
PKG_RELEASE:=1

PYPI_NAME:=Flask-SeaSurf
PKG_HASH:=54537008c769ac0ada8237877327c3e7ed74dcd8b01e74a9120ee0232c5951a9

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-flask-seasurf
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Updated CSRF extension for Flask
  URL:=https://github.com/maxcountryman/flask-seasurf
  DEPENDS:= \
    +python3-flask \
    +python3-light \
    +python3-urllib
endef

define Package/python3-flask-seasurf/description
SeaSurf is a Flask extension for preventing cross-site request forgery
(CSRF).
endef

$(eval $(call Py3Package,python3-flask-seasurf))
$(eval $(call BuildPackage,python3-flask-seasurf))
$(eval $(call BuildPackage,python3-flask-seasurf-src))
