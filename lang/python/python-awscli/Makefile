include $(TOPDIR)/rules.mk

PKG_NAME:=awscli
PKG_VERSION:=1.16.75
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/a/awscli
PKG_HASH:=8d96ec0de325ea8271cc6aa95b7392bbf548ec4aabd3ffbcdc0619b64edd4a45
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-awscli-$(PKG_VERSION)

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-awscli/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=awscli
  URL:=https://github.com/aws/aws-cli
endef

define Package/python-awscli
$(call Package/python-awscli/Default)
  DEPENDS:=+python \
	+python-yaml \
	+python-pyasn1 \
	+python-botocore \
	+python-rsa \
	+python-colorama \
	+python-docutils \
	+python-s3transfer
  VARIANT:=python
endef

define Package/python3-awscli
$(call Package/python-awscli/Default)
  DEPENDS:=+python3 \
	+python3-yaml \
	+python3-pyasn1 \
	+python3-botocore \
	+python3-rsa \
	+python3-colorama \
	+python3-docutils \
	+python3-s3transfer
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
