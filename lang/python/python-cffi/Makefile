#
# Copyright (C) 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-cffi
PKG_VERSION:=1.14.0
PKG_RELEASE:=1

PYPI_NAME:=cffi
PKG_HASH:=2d384f4a127a15ba701207f7639d94106693b6cd64173d6c8988e2c25f3ac2b6

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-cffi/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=C Foreign Function Interface
  URL:=https://cffi.readthedocs.org/
  DEPENDS:=+libffi
endef

define Package/python-cffi
$(call Package/python-cffi/Default)
  DEPENDS+= \
      +PACKAGE_python-cffi:python-light \
      +PACKAGE_python-cffi:python-pycparser
  VARIANT:=python
endef

define Package/python3-cffi
$(call Package/python-cffi/Default)
  DEPENDS+= \
      +PACKAGE_python3-cffi:python3-light \
      +PACKAGE_python3-cffi:python3-pycparser
  VARIANT:=python3
endef

define Package/python-cffi/description
Foreign Function Interface for Python calling C code.
endef

define Package/python3-cffi/description
$(call Package/python-cffi/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-cffi))
$(eval $(call BuildPackage,python-cffi))
$(eval $(call BuildPackage,python-cffi-src))

$(eval $(call Py3Package,python3-cffi))
$(eval $(call BuildPackage,python3-cffi))
$(eval $(call BuildPackage,python3-cffi-src))
