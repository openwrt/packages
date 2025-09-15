#
# Copyright (C) 2007-2019 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-requests
PKG_VERSION:=2.32.4
PKG_RELEASE:=1

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:python:requests

PYPI_NAME:=requests
PKG_HASH:=27d0316682c8a29834d3264820024b62a36942083d52caf2f14c0591336d3422

HOST_BUILD_DEPENDS:= \
  python-chardet/host \
  python-idna/host \
  python-urllib3/host \
  python-certifi/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-requests
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=HTTP library for Python
  URL:=https://requests.readthedocs.io
  DEPENDS:= \
	  +python3-light  \
	  +python3-chardet  \
	  +python3-idna  \
	  +python3-urllib3  \
	  +python3-certifi
endef

define Package/python3-requests/description
  Requests is the only Non-GMO HTTP library for Python, safe for human consumption
endef

$(eval $(call Py3Package,python3-requests))
$(eval $(call BuildPackage,python3-requests))
$(eval $(call BuildPackage,python3-requests-src))
$(eval $(call HostBuild))
