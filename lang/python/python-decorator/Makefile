# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-decorator
PKG_VERSION:=5.2.1
PKG_RELEASE:=1
PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com> 
PKG_CPE_ID:=cpe:/a:python:decorator

PYPI_NAME:=decorator
PKG_HASH:=65f266143752f734b0a7cc83c46f4618af75b8c5911b00ccb61d0ac9b6da0360

PKG_BUILD_DEPENDS:=python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-decorator
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/micheles/decorator
  TITLE:=python3-decodator
  DEPENDS:=+python3-light
endef

$(eval $(call Py3Package,python3-decorator))
$(eval $(call BuildPackage,python3-decorator))
$(eval $(call BuildPackage,python3-decorator-src))
