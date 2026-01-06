include $(TOPDIR)/rules.mk

PKG_NAME:=python-boto3
PKG_VERSION:=1.28.7
PKG_RELEASE:=1

PYPI_NAME:=boto3
PKG_HASH:=ef6a465d3b25b89bcd00ff69675b33917166145e544735dcb9978091f5b0b752

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-boto3
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=AWS SDK
  URL:=https://github.com/boto/boto3
  DEPENDS:= \
	+python3-light \
	+python3-decimal \
	+python3-logging \
	+python3-botocore \
	+python3-jmespath \
	+python3-s3transfer
endef

define Package/python3-boto3/description
Boto3 is the Amazon Web Services (AWS) Software Development Kit (SDK)
for Python, which allows Python developers to write software that makes
use of services like Amazon S3 and Amazon EC2.
endef

$(eval $(call Py3Package,python3-boto3))
$(eval $(call BuildPackage,python3-boto3))
$(eval $(call BuildPackage,python3-boto3-src))
