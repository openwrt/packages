include $(TOPDIR)/rules.mk

PKG_NAME:=django-cors-headers
PKG_VERSION:=3.1.1
PKG_RELEASE:=1

PYPI_NAME:=django-cors-headers
PKG_HASH:=5762ec9c2d59f38c76828dc1d4308baca4bc0d3e1d6f217683e7a24a1c4611a3

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
