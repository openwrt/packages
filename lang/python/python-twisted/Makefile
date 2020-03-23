#
# Copyright (C) 2006-2011, 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-twisted
PKG_VERSION:=20.3.0
PKG_RELEASE:=1

PYPI_NAME:=Twisted
PYPI_SOURCE_EXT:=tar.bz2
PKG_HASH:=d72c55b5d56e176563b91d11952d13b01af8725c623e498db5507b6614fc1e10

PKG_BUILD_DEPENDS:=libtirpc

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>
PKG_CPE_ID:=cpe:/a:twistedmatrix:twisted

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-twisted/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Asynchronous networking framework
  URL:=https://twistedmatrix.com/
endef

define Package/python-twisted
$(call Package/python-twisted/Default)
  DEPENDS:= \
      +PACKAGE_python-twisted:python-light \
      +PACKAGE_python-twisted:python-attrs \
      +PACKAGE_python-twisted:python-automat \
      +PACKAGE_python-twisted:python-constantly \
      +PACKAGE_python-twisted:python-incremental \
      +PACKAGE_python-twisted:python-hyperlink \
      +PACKAGE_python-twisted:python-setuptools \
      +PACKAGE_python-twisted:python-zope-interface
  VARIANT:=python
endef

define Package/python3-twisted
$(call Package/python-twisted/Default)
  DEPENDS:= \
      +PACKAGE_python3-twisted:python3-light \
      +PACKAGE_python3-twisted:python3-attrs \
      +PACKAGE_python3-twisted:python3-automat \
      +PACKAGE_python3-twisted:python3-constantly \
      +PACKAGE_python3-twisted:python3-incremental \
      +PACKAGE_python3-twisted:python3-hyperlink \
      +PACKAGE_python3-twisted:python3-setuptools \
      +PACKAGE_python3-twisted:python3-zope-interface
  VARIANT:=python3
endef

define Package/python-twisted/description
Twisted is a networking engine written in Python, supporting numerous
protocols. It contains a web server, numerous chat clients, chat servers,
mail servers, and more.
endef

define Package/python3-twisted/description
$(call Package/python-twisted/description)
.
(Variant for Python3)
endef

define PyPackage/python-twisted/filespec
+|$(PYTHON_PKG_DIR)
-|$(PYTHON_PKG_DIR)/twisted/conch/scripts/tkconch.py
endef

define Py3Package/python3-twisted/filespec
+|$(PYTHON3_PKG_DIR)
-|$(PYTHON3_PKG_DIR)/twisted/conch/scripts/tkconch.py
endef

define Py3Package/python3-twisted/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	for bin in $(1)/usr/bin/*; do \
		mv $$$$bin $$$${bin}3 ; \
	done
endef

$(eval $(call PyPackage,python-twisted))
$(eval $(call BuildPackage,python-twisted))
$(eval $(call BuildPackage,python-twisted-src))

$(eval $(call Py3Package,python3-twisted))
$(eval $(call BuildPackage,python3-twisted))
$(eval $(call BuildPackage,python3-twisted-src))
