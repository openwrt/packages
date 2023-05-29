# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-werkzeug
PKG_VERSION:=2.3.4
PKG_RELEASE:=1

PYPI_NAME:=Werkzeug
PKG_HASH:=1d5a58e0377d1fe39d061a5de4469e414e78ccb1e1e59c0f5ad6fa1c36c52b76

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.rst

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-werkzeug
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Comprehensive WSGI web application library
  URL:=https://palletsprojects.com/p/werkzeug/
  DEPENDS:=+python3 +python3-markupsafe
endef

define Package/python3-werkzeug/description
Werkzeug is a comprehensive WSGI web application library. It began as a
simple collection of various utilities for WSGI applications and has
become one of the most advanced WSGI utility libraries.
endef

$(eval $(call Py3Package,python3-werkzeug))
$(eval $(call BuildPackage,python3-werkzeug))
$(eval $(call BuildPackage,python3-werkzeug-src))
