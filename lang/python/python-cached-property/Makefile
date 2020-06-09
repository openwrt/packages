include $(TOPDIR)/rules.mk

PKG_NAME:=python-cached-property
PKG_VERSION:=1.5.1
PKG_RELEASE:=2

PYPI_NAME:=cached-property
PKG_HASH:=9217a59f14a5682da7c4b8829deadbfc194ac22e9908ccf7c8820234e80a1504

PKG_MAINTAINER:=Javier Marcet <javier@marcet.info>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

PYTHON3_PKG_SETUP_ARGS:=

define Package/python3-cached-property
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=A decorator for caching properties in classes
  URL:=https://github.com/pydanny/cached-property
  DEPENDS:=+python3-light
endef

define Package/python3-cached-property/description
  A decorator for caching properties in classes.
endef

$(eval $(call Py3Package,python3-cached-property))
$(eval $(call BuildPackage,python3-cached-property))
$(eval $(call BuildPackage,python3-cached-property-src))
