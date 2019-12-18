#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-urllib3
PKG_VERSION:=1.25.7
PKG_RELEASE:=1

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt
PKG_CPE_ID:=cpe:/a:urllib3_project:urllib3

PYPI_NAME:=urllib3
PKG_HASH:=f3c5fd51747d450d4dcf6f923c81f78f811aab8205fda64b0aba34a4e48b0745

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-urllib3/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Sanity-friendly HTTP client
  URL:=https://urllib3.readthedocs.io/
endef

define Package/python-urllib3
$(call Package/python-urllib3/Default)
  DEPENDS:=+PACKAGE_python-urllib3:python
  VARIANT:=python
endef

define Package/python-urllib3/description
  HTTP library with thread-safe connection pooling, file post, and more.
endef

define Package/python3-urllib3
$(call Package/python-urllib3/Default)
  DEPENDS:=+PACKAGE_python3-urllib3:python3
  VARIANT:=python3
endef

define Package/python3-urllib3/description
$(call Package/python-urllib3/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-urllib3))
$(eval $(call BuildPackage,python-urllib3))
$(eval $(call BuildPackage,python-urllib3-src))

$(eval $(call Py3Package,python3-urllib3))
$(eval $(call BuildPackage,python3-urllib3))
$(eval $(call BuildPackage,python3-urllib3-src))
