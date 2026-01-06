include $(TOPDIR)/rules.mk

PKG_NAME:=python-awscli
PKG_VERSION:=1.29.7
PKG_RELEASE:=1

PYPI_NAME:=awscli
PKG_HASH:=b3a7076cb317a21410a2d41734ba338add80f0480804cf9d68cbc52b1d39612a

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE.txt

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-awscli
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Universal Command Line Environment for AWS
  URL:=https://github.com/aws/aws-cli
  DEPENDS:=+python3 \
	+python3-botocore \
	+python3-colorama \
	+python3-docutils \
	+python3-rsa \
	+python3-s3transfer \
	+python3-yaml
endef

define Package/python3-awscli/description
This package provides a unified command line interface to Amazon Web
Services.
endef

$(eval $(call Py3Package,python3-awscli))
$(eval $(call BuildPackage,python3-awscli))
$(eval $(call BuildPackage,python3-awscli-src))
