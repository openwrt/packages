#
# Copyright (C) 2009-2015, 2017-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-crypto
PKG_VERSION:=2.6.1
PKG_RELEASE:=2

PKG_SOURCE:=pycrypto-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://ftp.dlitz.net/pub/dlitz/crypto/pycrypto/
PKG_HASH:=f2ce1e989b272cfcb677616763e0a2e7ec659effa67a88aa92b3a65528f60a3c

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-crypto-$(PKG_VERSION)

PKG_LICENSE:=Public Domain
PKG_LICENSE_FILES:=COPYRIGHT
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-crypto/Default
  SECTION:=lang-python
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=http://www.pycrypto.org/
endef

define Package/python-crypto
$(call Package/python-crypto/Default)
  TITLE:=python-crypto
  DEPENDS:=+libgmp +PACKAGE_python-crypto:python
  VARIANT:=python
endef

define Package/python3-crypto
$(call Package/python-crypto/Default)
  TITLE:=python3-crypto
  DEPENDS:=+libgmp +PACKAGE_python3-crypto:python3
  VARIANT:=python3
endef

define Package/python-crypto/description
A collection of both secure hash functions (such as MD5 and SHA),
and various encryption algorithms (AES, DES, IDEA, RSA, ElGamal, etc.).
endef

define Package/python3-crypto/description
$(call Package/python-crypto/description)
.
(Variant for Python3)
endef

define PyBuild/Compile
	$(call Build/Compile/PyMod,,\
		install --prefix=/usr --root=$(PKG_INSTALL_DIR),\
		CONFIG_BIG_ENDIAN="$(CONFIG_BIG_ENDIAN)" \
	)
endef

define Py3Build/Compile
	$(call Build/Compile/Py3Mod,,\
		install --prefix=/usr --root=$(PKG_INSTALL_DIR),\
		CONFIG_BIG_ENDIAN="$(CONFIG_BIG_ENDIAN)" \
	)
endef

$(eval $(call PyPackage,python-crypto))
$(eval $(call BuildPackage,python-crypto))
$(eval $(call BuildPackage,python-crypto-src))

$(eval $(call Py3Package,python3-crypto))
$(eval $(call BuildPackage,python3-crypto))
$(eval $(call BuildPackage,python3-crypto-src))
