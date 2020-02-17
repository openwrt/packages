include $(TOPDIR)/rules.mk

PKG_NAME:=python-paramiko
PKG_VERSION:=2.7.1
PKG_RELEASE:=1

PYPI_NAME:=paramiko
PKG_HASH:=920492895db8013f6cc0179293147f830b8c7b21fdfc839b6bad760c27459d9f

PKG_LICENSE:=LGPL-2.1-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Javier Marcet <javier@marcet.info>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

PYTHON3_PKG_SETUP_ARGS:=

define Package/python3-paramiko
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=SSH2 protocol library
  URL:=https://github.com/paramiko/paramiko/
  DEPENDS:=+python3-light +python3-bcrypt +python3-pynacl +python3-setuptools
  VARIANT:=python3
endef

define Package/python3-paramiko/description
  SSH2 protocol library
endef

$(eval $(call Py3Package,python3-paramiko))
$(eval $(call BuildPackage,python3-paramiko))
$(eval $(call BuildPackage,python3-paramiko-src))
