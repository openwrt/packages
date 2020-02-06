#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-yaml
PKG_VERSION:=5.3
PKG_RELEASE:=1

PYPI_NAME:=PyYAML
PKG_HASH:=e9f45bd5b92c7974e59bcd2dcc8631a6b6cc380a904725fce7bc08872e691615

PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:pyyaml_project:pyyaml

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-yaml/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=YAML parser and emitter for Python
  URL:=https://github.com/yaml/pyyaml
  DEPENDS:=+libyaml
endef

define Package/python-yaml
$(call Package/python-yaml/Default)
  DEPENDS+= \
	+PACKAGE_python-yaml:python-light \
	+PACKAGE_python-yaml:python-codecs
  VARIANT:=python
endef

define Package/python3-yaml
$(call Package/python-yaml/Default)
  DEPENDS+=+PACKAGE_python3-yaml:python3-light
  VARIANT:=python3
endef

define Package/python-yaml/description
  PyYAML is a YAML parser and emitter for the Python programming language.
endef

define Package/python3-yaml/description
$(call Package/python-yaml/description)
.
(Variant for Python3)
endef

PYTHON_PKG_SETUP_GLOBAL_ARGS:=--with-libyaml
PYTHON_PKG_SETUP_ARGS:=
PYTHON3_PKG_SETUP_GLOBAL_ARGS:=--with-libyaml
PYTHON3_PKG_SETUP_ARGS:=

$(eval $(call PyPackage,python-yaml))
$(eval $(call BuildPackage,python-yaml))
$(eval $(call BuildPackage,python-yaml-src))

$(eval $(call Py3Package,python3-yaml))
$(eval $(call BuildPackage,python3-yaml))
$(eval $(call BuildPackage,python3-yaml-src))
