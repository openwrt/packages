# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-werkzeug
PKG_VERSION:=3.1.8
PKG_RELEASE:=1

PYPI_NAME:=Werkzeug
PYPI_SOURCE_NAME:=werkzeug
PKG_HASH:=9bad61a4268dac112f1c5cd4630a56ede601b6ed420300677a869083d70a4c44

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.rst
PKG_CPE_ID:=cpe:/a:palletsprojects:werkzeug

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
