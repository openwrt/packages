include $(TOPDIR)/rules.mk

PKG_NAME:=python-paramiko
PKG_VERSION:=2.12.0
PKG_RELEASE:=2

PYPI_NAME:=paramiko
PKG_HASH:=376885c05c5d6aa6e1f4608aac2a6b5b0548b1add40274477324605903d9cd49

PKG_MAINTAINER:=Javier Marcet <javier@marcet.info>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:paramiko:paramiko

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

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
