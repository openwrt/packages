include $(TOPDIR)/rules.mk

PKG_NAME:=python-asgiref
PKG_VERSION:=3.11.1
PKG_RELEASE:=1

PYPI_NAME:=asgiref
PKG_HASH:=5f184dc43b7e763efe848065441eac62229c9f7b0475f41f80e207a114eda4ce

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
