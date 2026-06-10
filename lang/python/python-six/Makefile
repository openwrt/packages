#
# Copyright (C) 2015, 2017-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-six
PKG_VERSION:=1.17.0
PKG_RELEASE:=1

PYPI_NAME:=six
PKG_HASH:=ff70335d468e7eb6ec65b95b99d3a2836546063f63acc5171de367e834932a81

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DEPENDS:=python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-six
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python 2 and 3 compatibility library
  URL:=https://github.com/benjaminp/six
  DEPENDS:=+python3-light
endef

define Package/python3-six/description
Six is a Python 2 and 3 compatibility library.  It provides utility functions
for smoothing over the differences between the Python versions with the goal of
writing Python code that is compatible on both Python versions.  See the
documentation for more information on what is provided.
endef

$(eval $(call Py3Package,python3-six))
$(eval $(call BuildPackage,python3-six))
$(eval $(call BuildPackage,python3-six-src))
