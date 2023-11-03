include $(TOPDIR)/rules.mk

PKG_NAME:=python-jmespath
PKG_VERSION:=1.0.1
PKG_RELEASE:=1

PYPI_NAME:=jmespath
PKG_HASH:=90261b206d6defd58fdd5e85f478bf633a2901798906be2ad389150c5c60edbe

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-jmespath
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=JSON Matching Expressions
  URL:=https://github.com/jmespath/jmespath.py
  DEPENDS:=+python3-light
endef

define Package/python3-jmespath/description
JMESPath (pronounced “james path”) allows you to declaratively specify
how to extract elements from a JSON document.
endef

$(eval $(call Py3Package,python3-jmespath))
$(eval $(call BuildPackage,python3-jmespath))
$(eval $(call BuildPackage,python3-jmespath-src))
