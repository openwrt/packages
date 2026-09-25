#
# Copyright (C) 2022 Julien Malik <julien.malik@paraiso.me>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-async-generator
PKG_VERSION:=1.10
PKG_RELEASE:=2

PYPI_NAME:=async_generator
PKG_HASH:=6ebb3d106c12920aaae42ccb6f787ef5eefdcdd166ea3d628fa8476abe712144

PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=LICENSE.APACHE2 LICENSE.MIT
PKG_MAINTAINER:=Julien Malik <julien.malik@paraiso.me>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-async-generator
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Async generators and context managers for Python 3.5+
  URL:=https://github.com/python-trio/async_generator
  DEPENDS:=+python3-light
endef

define Package/python3-async-generator/description
  Python 3.6 added async generators. Python 3.7 adds some more tools to make them usable, like contextlib.asynccontextmanager.

  This library gives you all that back to Python 3.5.
endef

$(eval $(call Py3Package,python3-async-generator))
$(eval $(call BuildPackage,python3-async-generator))
$(eval $(call BuildPackage,python3-async-generator-src))
