include $(TOPDIR)/rules.mk

PKG_NAME:=drf-nested-routers
PKG_VERSION:=0.91
PKG_RELEASE:=2

PYPI_NAME:=drf-nested-routers
PKG_HASH:=46e5c3abc15c782cafafd7d75028e8f9121bbc6228e3599bbb48a3daa4585034

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Peter Stadler <peter.stadler@student.uibk.ac.at>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-drf-nested-routers
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Nested resources for the Django Rest Framework
  URL:=https://github.com/alanjds/drf-nested-routers
  DEPENDS:=+python3-django-restframework +django +python3-light
  VARIANT:=python3
endef

define Package/python3-drf-nested-routers/description
  Nested resources for the Django Rest Framework
endef

define Py3Package/python3-drf-nested-routers/filespec
+|$(PYTHON3_PKG_DIR)
-|$(PYTHON3_PKG_DIR)/rest_framework_nested/runtests
endef

$(eval $(call Py3Package,python3-drf-nested-routers))
$(eval $(call BuildPackage,python3-drf-nested-routers))
$(eval $(call BuildPackage,python3-drf-nested-routers-src))
