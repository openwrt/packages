include $(TOPDIR)/rules.mk

PKG_NAME:=awscli
PKG_VERSION:=1.16.75
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=8d96ec0de325ea8271cc6aa95b7392bbf548ec4aabd3ffbcdc0619b64edd4a45

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>
PKG_LICENSE:=MIT

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-awscli/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=awscli
  URL:=https://github.com/aws/aws-cli
endef

define Package/python-awscli
$(call Package/python-awscli/Default)
  DEPENDS:=+PACKAGE_python-awscli:python \
	+PACKAGE_python-awscli:python-yaml \
	+PACKAGE_python-awscli:python-pyasn1 \
	+PACKAGE_python-awscli:python-botocore \
	+PACKAGE_python-awscli:python-rsa \
	+PACKAGE_python-awscli:python-colorama \
	+PACKAGE_python-awscli:python-docutils \
	+PACKAGE_python-awscli:python-s3transfer
  VARIANT:=python
endef

define Package/python3-awscli
$(call Package/python-awscli/Default)
  DEPENDS:=+PACKAGE_python3-awscli:python3 \
	+PACKAGE_python3-awscli:python3-yaml \
	+PACKAGE_python3-awscli:python3-pyasn1 \
	+PACKAGE_python3-awscli:python3-botocore \
	+PACKAGE_python3-awscli:python3-rsa \
	+PACKAGE_python3-awscli:python3-colorama \
	+PACKAGE_python3-awscli:python3-docutils \
	+PACKAGE_python3-awscli:python3-s3transfer
  VARIANT:=python3
endef

define Package/python-awscli/description
This package provides a unified command line interface to Amazon Web Services.
endef

define Package/python3-awscli/description
$(call Package/python-awscli/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-awscli))
$(eval $(call BuildPackage,python-awscli))
$(eval $(call BuildPackage,python-awscli-src))

$(eval $(call Py3Package,python3-awscli))
$(eval $(call BuildPackage,python3-awscli))
$(eval $(call BuildPackage,python3-awscli-src))
