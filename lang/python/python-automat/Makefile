#
# Copyright (C) 2018-2020, 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-automat
PKG_VERSION:=22.10.0
PKG_RELEASE:=1

PYPI_NAME:=Automat
PKG_HASH:=e56beb84edad19dcc11d30e8d9b895f75deeb5ef5e96b84a467066b3b84bb04e

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_BUILD_DEPENDS:=python-setuptools-scm/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-automat
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Concise, idiomatic finite-state automata
  URL:=https://github.com/glyph/Automat
  DEPENDS:= \
      +python3-light \
      +python3-attrs \
      +python3-six
endef

define Package/python3-automat/description
Automat is a library for concise, idiomatic Python expression of
finite-state automata (particularly deterministic finite-state
transducers).
endef

define Py3Package/python3-automat/filespec
+|$(PYTHON3_PKG_DIR)
-|$(PYTHON3_PKG_DIR)/automat/_visualize.py
endef

$(eval $(call Py3Package,python3-automat))
$(eval $(call BuildPackage,python3-automat))
$(eval $(call BuildPackage,python3-automat-src))
