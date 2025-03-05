#
# Copyright (C) 2019-2020 CZ.NIC z.s.p.o. (http://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-flask-login
PKG_VERSION:=0.6.2
PKG_RELEASE:=1

PYPI_NAME:=Flask-Login
PKG_HASH:=c0a7baa9fdc448cdd3dd6f0939df72eec5177b2f7abe6cb82fc934d29caac9c3

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-flask-login
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=User authentication and session management for Flask
  URL:=https://github.com/maxcountryman/flask-login
  DEPENDS:=+python3-light +python3-urllib +python3-flask +python3-werkzeug
endef

define Package/python3-flask-login/description
  Flask-Login provides user session management for Flask.
  It handles the common tasks of logging in, logging out,
  and remembering your users’ sessions over extended periods of time.
endef

$(eval $(call Py3Package,python3-flask-login))
$(eval $(call BuildPackage,python3-flask-login))
$(eval $(call BuildPackage,python3-flask-login-src))
