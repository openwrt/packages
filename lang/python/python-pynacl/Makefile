include $(TOPDIR)/rules.mk

PKG_NAME:=python-pynacl
PKG_VERSION:=1.5.0
PKG_RELEASE:=3

PYPI_NAME:=PyNaCl
PYPI_SOURCE_NAME:=pynacl
PKG_HASH:=8ac7448f09ab85811607bdd21ec2464495ac8b7c66d146bf545b0f08fb9220ba

PKG_MAINTAINER:=Javier Marcet <javier@marcet.info>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=libffi/host python-cffi/host  # cffi>=1.4.1

PYTHON3_PKG_BUILD_VARS:=SODIUM_INSTALL=system

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pynacl
  CATEGORY:=Languages
  SECTION:=lang
  SUBMENU:=Python
  TITLE:=Python binding to the libsodium library
  URL:=https://github.com/pyca/pynacl/
  DEPENDS:=+libsodium +python3-light +python3-cffi +python3-six
endef

define Package/python3-pynacl/description
  PyNaCl is a Python binding to libsodium, which is a fork of the Networking and Cryptography library.
endef

$(eval $(call Py3Package,python3-pynacl))
$(eval $(call BuildPackage,python3-pynacl))
$(eval $(call BuildPackage,python3-pynacl-src))
