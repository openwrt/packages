include $(TOPDIR)/rules.mk

PKG_NAME:=python-botocore
PKG_VERSION:=1.44.10
PKG_RELEASE:=1

PYPI_NAME:=botocore
PKG_HASH:=6fc109eefd1b02899196499d798141be6df70ca257b399741adc9975569d41b6

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
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
