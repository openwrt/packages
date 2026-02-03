#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-dateutil
PKG_VERSION:=2.9.0
PKG_RELEASE:=1
PKG_LICENSE:=BSD-2-Clause

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=78e73e19c63f5b20ffa567001531680d939dc042bf7850431877645523c66709
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DEPENDS:=python-setuptools-scm/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk

include ../python3-package.mk

define Package/python3-dateutil
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Extensions to the standard Python datetime module
  URL:=https://dateutil.readthedocs.org/
  DEPENDS:=+python3 +python3-six
endef

define Package/python3-dateutil/description
  Extensions to the standard Python datetime module
endef

$(eval $(call Py3Package,python3-dateutil))
$(eval $(call BuildPackage,python3-dateutil))
$(eval $(call BuildPackage,python3-dateutil-src))
