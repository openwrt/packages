#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-dateutil
PKG_VERSION:=2.8.1
PKG_RELEASE:=1
PKG_LICENSE:=BSD-2-Clause

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=73ebfe9dbf22e832286dafa60473e4cd239f8592f699aa5adaf10050e6e1823c
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk

include ../python-package.mk
include ../python3-package.mk

define Package/python-dateutil/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Extensions to the standard Python datetime module
  URL:=https://dateutil.readthedocs.org/
endef

define Package/python-dateutil
$(call Package/python-dateutil/Default)
  DEPENDS:=+PACKAGE_python-dateutil:python +PACKAGE_python-dateutil:python-six
  VARIANT:=python
endef

define Package/python-dateutil/description
  Extensions to the standard Python datetime module
endef

define Package/python3-dateutil
$(call Package/python-dateutil/Default)
  DEPENDS:=+PACKAGE_python3-dateutil:python3 +PACKAGE_python3-dateutil:python3-six
  VARIANT:=python3
endef

define Package/python3-dateutil/description
$(call Package/python-dateutil/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-dateutil))
$(eval $(call BuildPackage,python-dateutil))
$(eval $(call BuildPackage,python-dateutil-src))
$(eval $(call Py3Package,python3-dateutil))
$(eval $(call BuildPackage,python3-dateutil))
$(eval $(call BuildPackage,python3-dateutil-src))
