#
# Copyright (C) 2024, Clouder Oy
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pydantic
PKG_VERSION:=2.8.2
PKG_RELEASE:=1

PYPI_NAME:=pydantic

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Ilkka Ollakka <ilkka.ollakka@cloudersolutions.com>
PKG_HASH:=6f62c13d067b0755ad1c21a34bdd06c0c12625a22b0fc09c6b149816604f7c2a

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pydantic
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Pydantic
  URL:=https://github.com/pydantic/pydantic
  DEPENDS:= \
      +python3-light \
      +python3-typing-extensions \
      +python3-annotated-types \
      +python3-pydantic-core
endef

define Package/python3-pydantic/description
Data validation using Python type hints.

Fast and extensible, Pydantic plays nicely with your linters/IDE/brain.
Define how data should be in pure, canonical Python 3.8+;
validate it with Pydantic.
endef

$(eval $(call Py3Package,python3-pydantic))
$(eval $(call BuildPackage,python3-pydantic))
$(eval $(call BuildPackage,python3-pydantic-src))
