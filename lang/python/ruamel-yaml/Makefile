#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ruamel-yaml
PKG_VERSION:=0.17.17
PKG_RELEASE:=$(AUTORELEASE)

PYPI_NAME:=ruamel.yaml
PKG_HASH:=9751de4cbb57d4bfbf8fc394e125ed4a2f170fbff3dc3d78abf50be85924f8be

PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-ruamel-yaml
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=YAML 1.2 loader/dumper package for Python
  URL:=https://bitbucket.org/ruamel/yaml
  DEPENDS:= \
      +python3-light
endef

define Package/python3-ruamel-yaml/description
ruamel-yaml is a YAML parser/emitter that supports roundtrip preservation of comments, seq/map flow style, and map key order
endef

$(eval $(call Py3Package,python3-ruamel-yaml))
$(eval $(call BuildPackage,python3-ruamel-yaml))
$(eval $(call BuildPackage,python3-ruamel-yaml-src))
