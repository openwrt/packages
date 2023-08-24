include $(TOPDIR)/rules.mk

PKG_NAME:=python-rsa
PKG_VERSION:=4.9
PKG_RELEASE:=1

PYPI_NAME:=rsa
PKG_HASH:=e38464a49c6c85d7f1351b0126661487a7e0a14a50f1675ec50eb34d4f20ef21

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:python-rsa_project:python-rsa

PKG_BUILD_DEPENDS:=python-poetry-core/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-rsa
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Pure-Python RSA implementation
  URL:=https://stuvel.eu/rsa
  DEPENDS:=+python3-light +python3-multiprocessing +python3-pydoc +python3-pyasn1
endef

define Package/python3-rsa/description
Python-RSA is a pure-Python RSA implementation. It supports encryption
and decryption, signing and verifying signatures, and key generation
according to PKCS#1 version 1.5. It can be used as a Python library as
well as on the commandline.
endef

$(eval $(call Py3Package,python3-rsa))
$(eval $(call BuildPackage,python3-rsa))
$(eval $(call BuildPackage,python3-rsa-src))
