include $(TOPDIR)/rules.mk

PKG_NAME:=django-cors-headers
PKG_VERSION:=3.2.0
PKG_RELEASE:=1

PYPI_NAME:=django-cors-headers
PKG_HASH:=84933651fbbde8f2bc084bef2f077b79db1ec1389432f21dd661eaae6b3d6a95

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Peter Stadler <peter.stadler@student.uibk.ac.at>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-django-cors-headers
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Django application for handling the server headers required for Cross-Origin Resource Sharing (CORS).
  URL:=https://github.com/ottoyiu/django-cors-headers
  DEPENDS:=python3-django +python3-urllib +python3-light
  VARIANT:=python3
  MDEPENDS:=python3-django
endef

define Package/python3-django-cors-headers/description
  Django application for handling the server headers required for Cross-Origin Resource Sharing (CORS).
endef

$(eval $(call Py3Package,python3-django-cors-headers))
$(eval $(call BuildPackage,python3-django-cors-headers))
$(eval $(call BuildPackage,python3-django-cors-headers-src))
