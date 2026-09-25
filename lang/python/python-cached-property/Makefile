include $(TOPDIR)/rules.mk

PKG_NAME:=python-cached-property
PKG_VERSION:=2.0.1
PKG_RELEASE:=1

PYPI_NAME:=cached-property
PYPI_SOURCE_NAME:=cached_property
PKG_HASH:=484d617105e3ee0e4f1f58725e72a8ef9e93deee462222dbd51cd91230897641

PKG_BUILD_DEPENDS:=python-setuptools/host

PKG_MAINTAINER:=Javier Marcet <javier@marcet.info>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-cached-property
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=A decorator for caching properties in classes
  URL:=https://github.com/pydanny/cached-property
  DEPENDS:=+python3-light +python3-asyncio +python3-logging
endef

define Package/python3-cached-property/description
  A decorator for caching properties in classes.
endef

$(eval $(call Py3Package,python3-cached-property))
$(eval $(call BuildPackage,python3-cached-property))
$(eval $(call BuildPackage,python3-cached-property-src))
