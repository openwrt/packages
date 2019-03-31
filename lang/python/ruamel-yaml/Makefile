#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ruamel-yaml
PKG_VERSION:=0.15.89
PKG_RELEASE:=1

PKG_SOURCE:=ruamel.yaml-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/r/ruamel.yaml/
PKG_HASH:=86d034aa9e2ab3eacc5f75f5cd6a469a2af533b6d9e60ea92edbba540d21b9b7

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-ruamel.yaml-$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/ruamel-yaml/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=YAML 1.2 loader/dumper package for Python
  URL:=https://bitbucket.org/ruamel/yaml
endef

define Package/python-ruamel-yaml
$(call Package/ruamel-yaml/Default)
  DEPENDS:= \
      +PACKAGE_python-ruamel-yaml:python-light
  VARIANT:=python
endef

define Package/python3-ruamel-yaml
$(call Package/ruamel-yaml/Default)
  DEPENDS:= \
      +PACKAGE_python3-ruamel-yaml:python3-light
  VARIANT:=python3
endef

define Package/ruamel-yaml/description
ruamel-yaml is a YAML parser/emitter that supports roundtrip preservation of comments, seq/map flow style, and map key order
endef

define Package/python3-ruamel-yaml/description
$(call Package/ruamel-yaml/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-ruamel-yaml))
$(eval $(call BuildPackage,python-ruamel-yaml))
$(eval $(call BuildPackage,python-ruamel-yaml-src))

$(eval $(call Py3Package,python3-ruamel-yaml))
$(eval $(call BuildPackage,python3-ruamel-yaml))
$(eval $(call BuildPackage,python3-ruamel-yaml-src))
