include $(TOPDIR)/rules.mk

PKG_NAME:=drf-nested-routers
PKG_VERSION:=0.95.0
PKG_RELEASE:=1

PYPI_NAME:=drf-nested-routers
PYPI_SOURCE_NAME:=drf_nested_routers
PKG_HASH:=815978f802e578fd7035c74040c104909cbe97615de89a275d77e928f4029891

PKG_MAINTAINER:=Peter Stadler <peter.stadler@student.uibk.ac.at>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

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
