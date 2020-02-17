include $(TOPDIR)/rules.mk

PKG_NAME:=python-pynacl
PKG_VERSION:=1.3.0
PKG_RELEASE:=1

PYPI_NAME:=PyNaCl
PKG_HASH:=0c6100edd16fefd1557da078c7a31e7b7d7a52ce39fdca2bec29d4f7b6e7600c

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Javier Marcet <javier@marcet.info>

PKG_BUILD_DEPENDS:=libffi/host

HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:="cffi>=1.4.1"

PYTHON3_PKG_SETUP_VARS:= SODIUM_INSTALL=system

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pynacl
  CATEGORY:=Languages
  SECTION:=lang
  SUBMENU:=Python
  TITLE:=Python binding to the Networking and Cryptography (NaCl) library
  URL:=https://github.com/pyca/pynacl/
  DEPENDS:=+libsodium +python3-light +python3-cffi +python3-distutils +python3-setuptools +python3-six
  VARIANT:=python3
endef

define Package/python3-pynacl/description
  PyNaCl is a Python binding to libsodium, which is a fork of the Networking and Cryptography library.
endef

$(eval $(call Py3Package,python3-pynacl))
$(eval $(call BuildPackage,python3-pynacl))
$(eval $(call BuildPackage,python3-pynacl-src))
