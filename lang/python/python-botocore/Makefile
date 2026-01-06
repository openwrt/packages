include $(TOPDIR)/rules.mk

PKG_NAME:=python-botocore
PKG_VERSION:=1.31.7
PKG_RELEASE:=1

PYPI_NAME:=botocore
PKG_HASH:=f4473f66c153c262b8262404d737f4249366daf00fb068b495577a24b830ebcb

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
