#
# Copyright (C) 2024, Clouder Oy
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-annotated-types
PKG_VERSION:=0.7.0
PKG_RELEASE:=1

PYPI_NAME:=annotated_types

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Ilkka Ollakka <ilkka.ollakka@cloudersolutions.com>
PKG_HASH:=aff07c09a53a08bc8cfccb9c85b05f1aa9a2a6f23728d790723543408344ce89

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-annotated-types
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Annotated-types
  URL:=https://github.com/annotated-types/annotated-types
  DEPENDS:= \
      +python3-light \
      +python3-typing-extensions
endef

define Package/python3-annotated-types/description
PEP-593 added typing.Annotated as a way of adding context-specific metadata to existing types, and specifies that Annotated[T, x] should be treated as T by any tool or library without special logic for x.

This package provides metadata objects which can be used to represent common constraints such as upper and lower bounds on scalar values and collection sizes, a Predicate marker for runtime checks, and descriptions of how we intend these metadata to be interpreted. In some cases, we also note alternative representations which do not require this package.
endef

$(eval $(call Py3Package,python3-annotated-types))
$(eval $(call BuildPackage,python3-annotated-types))
$(eval $(call BuildPackage,python3-annotated-types-src))
