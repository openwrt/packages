include $(TOPDIR)/rules.mk

PKG_NAME:=django-cors-headers
PKG_VERSION:=3.3.0
PKG_RELEASE:=1

PYPI_NAME:=django-cors-headers
PKG_HASH:=73d654950b5f5e7e4f67c05183d2169d4f7518ceb87734eb0d68f9e43be59f1c

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
  DEPENDS:=+django +python3-urllib +python3-light
endef

define Package/python3-django-cors-headers/description
  Django application for handling the server headers required for Cross-Origin Resource Sharing (CORS).
endef

$(eval $(call Py3Package,python3-django-cors-headers))
$(eval $(call BuildPackage,python3-django-cors-headers))
$(eval $(call BuildPackage,python3-django-cors-headers-src))
