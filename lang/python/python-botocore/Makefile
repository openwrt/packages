include $(TOPDIR)/rules.mk

PKG_NAME:=botocore
PKG_VERSION:=1.12.66
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=25c39ecc71356287cf79d66981ec77deca374e28043b19b2f818d48aa34272a1

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>
PKG_LICENSE:=MIT

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-botocore/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=botocore
  URL:=https://github.com/boto/botocore
endef

define Package/python-botocore
$(call Package/python-botocore/Default)
  DEPENDS:=+PACKAGE_python-botocore:python \
	+PACKAGE_python-botocore:python-urllib3 \
	+PACKAGE_python-botocore:python-docutils \
	+PACKAGE_python-botocore:python-dateutil \
	+PACKAGE_python-botocore:python-jmespath \
	+PACKAGE_python-botocore:python-requests
  VARIANT:=python
endef

define Package/python3-botocore
$(call Package/python-botocore/Default)
  DEPENDS:=+PACKAGE_python3-botocore:python3 \
	+PACKAGE_python3-botocore:python3-urllib3 \
	+PACKAGE_python3-botocore:python3-docutils \
	+PACKAGE_python3-botocore:python3-dateutil \
	+PACKAGE_python3-botocore:python3-jmespath \
	+PACKAGE_python3-botocore:python3-requests
  VARIANT:=python3
endef

define Package/python-botocore/description
A low-level interface to a growing number of Amazon Web Services.
The botocore package is the foundation for the AWS CLI as well as boto3.
endef

define Package/python3-botocore/description
$(call Package/python-botocore/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-botocore))
$(eval $(call BuildPackage,python-botocore))
$(eval $(call BuildPackage,python-botocore-src))

$(eval $(call Py3Package,python3-botocore))
$(eval $(call BuildPackage,python3-botocore))
$(eval $(call BuildPackage,python3-botocore-src))
