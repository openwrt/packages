include $(TOPDIR)/rules.mk

PKG_NAME:=python-botocore
PKG_VERSION:=1.42.86
PKG_RELEASE:=1

PYPI_NAME:=botocore
PKG_HASH:=baa49e93b4c92d63e0c8288026ee1ef8de83f182743127cc9175504440a48e49

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE.txt

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-botocore
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Low-level, data-driven core of boto 3
  URL:=https://github.com/boto/botocore
  DEPENDS:=+python3 \
	+python3-dateutil \
	+python3-jmespath \
	+python3-urllib3
endef

define Package/python3-botocore/description
A low-level interface to a growing number of Amazon Web Services. The
botocore package is the foundation for the AWS CLI as well as boto3.
endef

$(eval $(call Py3Package,python3-botocore))
$(eval $(call BuildPackage,python3-botocore))
$(eval $(call BuildPackage,python3-botocore-src))
