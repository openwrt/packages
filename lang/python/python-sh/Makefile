# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-sh
PKG_VERSION:=2.4.0
PKG_RELEASE:=1

PYPI_NAME:=sh
PKG_HASH:=a250aef68509ed93419c9a1d90b0647cd5cbe26107ba94d3717ef5b6d595ffd9
PKG_SOURCE:=$(PYPI_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/e9/c8/137093889a8b8c9a66c9b46079cf2a0e155a8be027df212a4041e3b7b09c

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Ilja Honkonen <openwrt_1@honkonen.email>
PKG_CPE_ID:=cpe:/a:python:python-sh

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-sh
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python process launching
  URL:=https://github.com/amoffat/sh/
  DEPENDS:=+python3
endef

define Package/python3-sh/description
  sh is a full-fledged subprocess replacement for Python 3.10+ and
  PyPy that allows you to call any program as if it were a function.
endef

$(eval $(call Py3Package,python3-sh))
$(eval $(call BuildPackage,python3-sh))
$(eval $(call BuildPackage,python3-sh-src))
