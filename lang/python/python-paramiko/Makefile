include $(TOPDIR)/rules.mk

PKG_NAME:=python-paramiko
PKG_VERSION:=3.5.1
PKG_RELEASE:=1

PYPI_NAME:=paramiko
PKG_HASH:=b2c665bc45b2b215bd7d7f039901b14b067da00f3a11e6640995fd58f2664822

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
  Paramiko is a pure-Python (3.6+) implementation of the SSHv2 protocol,
  providing both client and server functionality. It provides the foundation
  for the high-level SSH library Fabric, which is what we recommend you use
  for common client use-cases such as running remote shell commands or
  transferring files.
endef

$(eval $(call Py3Package,python3-paramiko))
$(eval $(call BuildPackage,python3-paramiko))
$(eval $(call BuildPackage,python3-paramiko-src))
