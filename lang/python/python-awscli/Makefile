include $(TOPDIR)/rules.mk

PKG_NAME:=awscli
PKG_VERSION:=1.27.146
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=aws-cli-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/aws/aws-cli.git
PKG_SOURCE_DATE:=2023-06-02
PKG_SOURCE_VERSION:=e5f2007f27b067d34fb882bd907e2ad50a60823d
PKG_MIRROR_HASH:=24b2f233140376ebb6aec6fb2dd3a9734bc1934896069f90d00785c81d121ced

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>  ExtraIoT <soporte@extraiot.com.mx>
PKG_LICENSE:=MIT

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-awscli
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=awscli
  URL:=https://github.com/aws/aws-cli
  DEPENDS:=+python3 \
	+python3-yaml \
	+python3-pyasn1 \
	+python3-botocore \
	+python3-rsa \
	+python3-colorama \
	+python3-docutils \
	+python3-s3transfer
endef

define Package/python3-awscli/description
This package provides a unified command line interface to Amazon Web Services.
endef

$(eval $(call Py3Package,python3-awscli))
$(eval $(call BuildPackage,python3-awscli))
$(eval $(call BuildPackage,python3-awscli-src))
