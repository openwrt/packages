include $(TOPDIR)/rules.mk

PKG_NAME:=python-paramiko
PKG_VERSION:=2.10.1
PKG_RELEASE:=1

PYPI_NAME:=paramiko
PKG_HASH:=443f4da23ec24e9a9c0ea54017829c282abdda1d57110bf229360775ccd27a31

PKG_MAINTAINER:=Javier Marcet <javier@marcet.info>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE

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
  DEPENDS:=+python3-light +python3-logging +python3-bcrypt \
	  +python3-cryptography +python3-openssl +python3-pynacl
endef

define Package/python3-paramiko/description
  Paramiko is a Python (2.7, 3.4+) implementation of the SSHv2 protocol,
  providing both client and server functionality. While it leverages a Python
  C extension for low level cryptography (Cryptography), Paramiko itself is a
  pure Python interface around SSH networking concepts.
endef

$(eval $(call Py3Package,python3-paramiko))
$(eval $(call BuildPackage,python3-paramiko))
$(eval $(call BuildPackage,python3-paramiko-src))
