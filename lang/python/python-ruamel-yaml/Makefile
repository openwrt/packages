#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-ruamel-yaml
PKG_VERSION:=0.19.1
PKG_RELEASE:=1

PYPI_NAME:=ruamel.yaml
PYPI_SOURCE_NAME:=ruamel_yaml
PYTHON3_PKG_WHEEL_NAME:=ruamel_yaml
PKG_HASH:=53eb66cd27849eff968ebf8f0bf61f46cdac2da1d1f3576dd4ccee9b25c31993

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:ruamel.yaml_project:ruamel.yaml

include ../pypi.mk
# Override PKG_BUILD_DIR: the sdist filename uses underscores (ruamel_yaml-*.tar.gz)
# but the tarball extracts to ruamel.yaml-*/ (with dot), so adjust accordingly.
PKG_BUILD_DIR:=$(BUILD_DIR)/pypi/ruamel.yaml-$(PKG_VERSION)
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-ruamel-yaml
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=YAML 1.2 loader/dumper
  URL:=https://sourceforge.net/p/ruamel-yaml/code/ci/default/tree
  DEPENDS:= \
      +python3-light
endef

define Package/python3-ruamel-yaml/description
ruamel-yaml is a YAML parser/emitter that supports roundtrip
preservation of comments, seq/map flow style, and map key order
endef

$(eval $(call Py3Package,python3-ruamel-yaml))
$(eval $(call BuildPackage,python3-ruamel-yaml))
$(eval $(call BuildPackage,python3-ruamel-yaml-src))
