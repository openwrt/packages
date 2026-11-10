include $(TOPDIR)/rules.mk

PKG_NAME:=python-asgiref
PKG_VERSION:=3.13.0
PKG_RELEASE:=1

PYPI_NAME:=asgiref
PKG_HASH:=034cc8cbf72d00553b4be256703ac545120b4e50af13b49dec99da899aeeecb4

PKG_BUILD_DEPENDS:=python-setuptools/host

PKG_MAINTAINER:=Peter Stadler <peter.stadler@student.uibk.ac.at>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-asgiref
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=ASGI specs, helper code, and adapters
  URL:=https://github.com/django/asgiref/
  DEPENDS:=+python3-light +python3-logging +python3-asyncio
endef

define Package/python3-asgiref/description
  ASGI is a standard for Python asynchronous web apps and servers to communicate
  with each other, and positioned as an asynchronous successor to WSGI.
endef

$(eval $(call Py3Package,python3-asgiref))
$(eval $(call BuildPackage,python3-asgiref))
$(eval $(call BuildPackage,python3-asgiref-src))
