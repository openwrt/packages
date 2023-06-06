include $(TOPDIR)/rules.mk

PKG_NAME:=botocore
PKG_VERSION:=1.29.146
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=botocore-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/boto/botocore.git
PKG_SOURCE_DATE:=2023-06-02
PKG_SOURCE_VERSION:=6105816af4f29d5baa574b54ed83c056027c6606
PKG_MIRROR_HASH:=2346e3a1b589f12da1f18fba49aadee04c170fc5c9529ab8734a1f98bb029c72

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com> ExtraIoT <soporte@extraiot.com.mx>
PKG_LICENSE:=MIT

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-botocore
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=botocore
  URL:=https://github.com/boto/botocore
  DEPENDS:=+python3 \
	+python3-urllib3 \
	+python3-docutils \
	+python3-dateutil \
	+python3-jmespath \
	+python3-requests
endef

define Package/python3-botocore/description
A low-level interface to a growing number of Amazon Web Services.
The botocore package is the foundation for the AWS CLI as well as boto3.
endef

$(eval $(call Py3Package,python3-botocore))
$(eval $(call BuildPackage,python3-botocore))
$(eval $(call BuildPackage,python3-botocore-src))
