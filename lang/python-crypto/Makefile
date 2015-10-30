#
# Copyright (C) 2009-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pycrypto
PKG_VERSION:=2.6.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://ftp.dlitz.net/pub/dlitz/crypto/pycrypto/
PKG_MD5SUM:=55a61a054aa66812daf5161a0d5d7eda

PKG_LICENSE:=Public Domain
PKG_LICENSE_FILES:=COPYRIGHT
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-crypto
	SECTION:=lang-python
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=python-crypto
	URL:=http://www.pycrypto.org/
	DEPENDS:=+python +libgmp
endef

define Package/python-crypto/description
A collection of both secure hash functions (such as MD5 and SHA),
and various encryption algorithms (AES, DES, IDEA, RSA, ElGamal, etc.).
endef

define Build/Compile
	$(call Build/Compile/PyMod,,\
		install --prefix=/usr --root=$(PKG_INSTALL_DIR),\
		CONFIG_BIG_ENDIAN="$(CONFIG_BIG_ENDIAN)" \
	)
endef

define Package/python-crypto/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)/
	$(CP) \
		$(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
		$(1)$(PYTHON_PKG_DIR)/
endef

$(eval $(call PyPackage,python-crypto))
$(eval $(call BuildPackage,python-crypto))
