#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-yaml
PKG_VERSION:=5.1.2
PKG_RELEASE:=1

PKG_SOURCE:=PyYAML-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/P/PyYAML
PKG_HASH:=01adf0b6c6f61bd11af6e10ca52b7d4057dd0be0343eb9283c878cf3af56aee4

PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:pyyaml_project:pyyaml

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-PyYAML-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

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
