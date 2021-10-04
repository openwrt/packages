include $(TOPDIR)/rules.mk

PKG_NAME:=python-jsonschema
PKG_VERSION:=4.0.1
PKG_RELEASE:=1

PYPI_NAME:=jsonschema
PKG_HASH:=48f4e74f8bec0c2f75e9fcfffa264e78342873e1b57e2cfeae54864cc5e9e4dd

PKG_MAINTAINER:=Javier Marcet <javier@marcet.info>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:=setuptools-scm

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-jsonschema
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=An implementation of JSON Schema validation
  URL:=https://github.com/Julian/jsonschema
  DEPENDS:=+python3-light +python3-attrs +python3-urllib \
	  +python3-six +python3-pyrsistent +python3-setuptools
endef

define Package/python3-jsonschema/description
  jsonschema is an implementation of JSON Schema validation for Python.
endef

$(eval $(call Py3Package,python3-jsonschema))
$(eval $(call BuildPackage,python3-jsonschema))
$(eval $(call BuildPackage,python3-jsonschema-src))
