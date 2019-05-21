include $(TOPDIR)/rules.mk

PKG_NAME:=s3transfer
PKG_VERSION:=0.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/s/s3transfer
PKG_HASH:=f23d5cb7d862b104401d9021fc82e5fa0e0cf57b7660a1331425aab0c691d021
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-s3transfer-$(PKG_VERSION)

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-s3transfer/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=s3transfer
  URL:=https://github.com/boto/s3transfer
endef

define Package/python-s3transfer
$(call Package/python-s3transfer/Default)
  DEPENDS:= \
	+PACKAGE_python-s3transfer:python \
	+PACKAGE_python-s3transfer:python-botocore \
	+PACKAGE_python-s3transfer:python-futures
  VARIANT:=python
endef

define Package/python3-s3transfer
$(call Package/python-s3transfer/Default)
  DEPENDS:= \
	+PACKAGE_python3-s3transfer:python3 \
	+PACKAGE_python3-s3transfer:python3-botocore
  VARIANT:=python3
endef

define Package/python-s3transfer/description
S3transfer is a Python library for managing Amazon S3 transfers.
endef

define Package/python3-s3transfer/description
$(call Package/python-s3transfer/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-s3transfer))
$(eval $(call BuildPackage,python-s3transfer))
$(eval $(call BuildPackage,python-s3transfer-src))

$(eval $(call Py3Package,python3-s3transfer))
$(eval $(call BuildPackage,python3-s3transfer))
$(eval $(call BuildPackage,python3-s3transfer-src))
