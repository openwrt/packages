include $(TOPDIR)/rules.mk

PKG_NAME:=rsa

ifeq ($(BUILD_VARIANT),python3)
PKG_VERSION:=4.6
PKG_HASH:=109ea5a66744dd859bf16fe904b8d8b627adafb9408753161e766a92e7d681fa
else
PKG_VERSION:=4.5
PKG_HASH:=4d409f5a7d78530a4a2062574c7bd80311bc3af29b364e293aa9b03eea77714f
endif

PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>
PKG_LICENSE:=MIT
PKG_CPE_ID:=cpe:/a:python-rsa_project:python-rsa

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
