include $(TOPDIR)/rules.mk

PKG_NAME:=rsa
PKG_VERSION:=4.0
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=1a836406405730121ae9823e19c6e806c62bbad73f890574fff50efa4122c487

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>
PKG_LICENSE:=MIT

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-rsa/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=rsa
  URL:=https://stuvel.eu/rsa
endef

define Package/python-rsa
$(call Package/python-rsa/Default)
  DEPENDS:=+PACKAGE_python-rsa:python +PACKAGE_python-rsa:python-pyasn1
  VARIANT:=python
endef

define Package/python3-rsa
$(call Package/python-rsa/Default)
  DEPENDS:=+PACKAGE_python3-rsa:python3 +PACKAGE_python3-rsa:python3-pyasn1
  VARIANT:=python3
endef

define Package/python-rsa/description
  Is a pure-Python RSA implementation. It supports encryption and decryption,
  signing and verifying signatures, and key generation according to PKCS#1 version 1.5.
  It can be used as a Python library as well as on the commandline. 
endef

define Package/python3-rsa/description
$(call Package/python-rsa/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-rsa))
$(eval $(call BuildPackage,python-rsa))
$(eval $(call BuildPackage,python-rsa-src))

$(eval $(call Py3Package,python3-rsa))
$(eval $(call BuildPackage,python3-rsa))
$(eval $(call BuildPackage,python3-rsa-src))
