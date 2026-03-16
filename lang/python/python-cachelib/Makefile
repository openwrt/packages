# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-cachelib
PKG_VERSION:=0.10.2
PKG_RELEASE:=1

PYPI_NAME:=cachelib
PKG_HASH:=593faeee62a7c037d50fc835617a01b887503f972fb52b188ae7e50e9cb69740

PKG_MAINTAINER:=Stepan Henek <stepan.henek@nic.cz>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.rst

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-cachelib
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Collection of cache libraries
  URL:=https://github.com/pallets-eco/cachelib/
  DEPENDS:=+python3-light +python3-logging
endef

define Package/python3-cachelib/description
  A collection of cache libraries in the same API interface.
  Extracted from werkzeug.
endef

$(eval $(call Py3Package,python3-cachelib))
$(eval $(call BuildPackage,python3-cachelib))
$(eval $(call BuildPackage,python3-cachelib-src))
