#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-yaml
PKG_VERSION:=5.4.1
PKG_RELEASE:=1

PYPI_NAME:=PyYAML
PKG_HASH:=607774cbba28732bfa802b54baa7484215f530991055bb562efbed5b2f20a45e

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:pyyaml_project:pyyaml

PKG_BUILD_DEPENDS:=python-cython/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-yaml
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=YAML parser and emitter
  URL:=https://github.com/yaml/pyyaml
  DEPENDS:=+libyaml +python3-light
endef

define Package/python3-yaml/description
  PyYAML is a YAML parser and emitter for the Python programming language.
endef

PYTHON3_PKG_BUILD_VARS:=PYYAML_FORCE_LIBYAML=1

$(eval $(call Py3Package,python3-yaml))
$(eval $(call BuildPackage,python3-yaml))
$(eval $(call BuildPackage,python3-yaml-src))
