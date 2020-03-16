#
# Copyright (C) 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pycparser
PKG_VERSION:=2.20
PKG_RELEASE:=1

PYPI_NAME:=pycparser
PKG_HASH:=2d475327684562c3a96cc71adf7dc8c4f0565175cf86b6d7a404ff4c771f15f0

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

HOST_PYTHON_PACKAGE_BUILD_DEPENDS:="ply==3.10"
HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:="ply==3.10"

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-pycparser/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=C parser in Python
  URL:=https://github.com/eliben/pycparser
endef

define Package/python-pycparser
$(call Package/python-pycparser/Default)
  DEPENDS:= \
      +PACKAGE_python-pycparser:python-light \
      +PACKAGE_python-pycparser:python-ply
  VARIANT:=python
endef

define Package/python3-pycparser
$(call Package/python-pycparser/Default)
  DEPENDS:= \
      +PACKAGE_python3-pycparser:python3-light \
      +PACKAGE_python3-pycparser:python3-ply
  VARIANT:=python3
endef

define Package/python-pycparser/description
pycparser is a parser for the C language, written in pure Python. It is a
module designed to be easily integrated into applications that need to parse
C source code.
endef

define Package/python3-pycparser/description
$(call Package/python-pycparser/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-pycparser))
$(eval $(call BuildPackage,python-pycparser))
$(eval $(call BuildPackage,python-pycparser-src))

$(eval $(call Py3Package,python3-pycparser))
$(eval $(call BuildPackage,python3-pycparser))
$(eval $(call BuildPackage,python3-pycparser-src))
