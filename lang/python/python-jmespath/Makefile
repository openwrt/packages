include $(TOPDIR)/rules.mk

PKG_NAME:=jmespath
PKG_VERSION:=0.9.3
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=6a81d4c9aa62caf061cb517b4d9ad1dd300374cd4706997aff9cd6aedd61fc64

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>
PKG_LICENSE:=MIT

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-jmespath/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=jmespath
  URL:=https://github.com/jmespath/jmespath.py
endef

define Package/python-jmespath
$(call Package/python-jmespath/Default)
  DEPENDS:=+PACKAGE_python-jmespath:python
  VARIANT:=python
endef

define Package/python3-jmespath
$(call Package/python-jmespath/Default)
  DEPENDS:=+PACKAGE_python3-jmespath:python3
  VARIANT:=python3
endef

define Package/python-jmespath/description
  JMESPath (pronounced “james path”) allows you to declaratively specify how to extract
  elements from a JSON document.
endef

define Package/python3-jmespath/description
$(call Package/python-jmespath/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-jmespath))
$(eval $(call BuildPackage,python-jmespath))
$(eval $(call BuildPackage,python-jmespath-src))

$(eval $(call Py3Package,python3-jmespath))
$(eval $(call BuildPackage,python3-jmespath))
$(eval $(call BuildPackage,python3-jmespath-src))
