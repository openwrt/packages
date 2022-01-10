include $(TOPDIR)/rules.mk

PKG_NAME:=asgiref
PKG_VERSION:=3.4.1
PKG_RELEASE:=$(AUTORELEASE)

PYPI_NAME:=asgiref
PKG_HASH:=4ef1ab46b484e3c706329cedeff284a5d40824200638503f5768edb6de7d58e9

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
  TITLE:=Standard for Python asynchronous web apps and servers.
  URL:=https://asgi.readthedocs.io/en/latest/
  DEPENDS:=+python3-light +python3-logging +python3-asyncio
endef

define Package/python3-asgiref/description
  ASGI is a standard for Python asynchronous web apps and servers to communicate
  with each other, and positioned as an asynchronous successor to WSGI.
endef

$(eval $(call Py3Package,python3-asgiref))
$(eval $(call BuildPackage,python3-asgiref))
$(eval $(call BuildPackage,python3-asgiref-src))
