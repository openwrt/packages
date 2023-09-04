#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-ruamel-yaml
PKG_VERSION:=0.17.32
PKG_RELEASE:=1

PYPI_NAME:=ruamel.yaml
PKG_HASH:=ec939063761914e14542972a5cba6d33c23b0859ab6342f61cf070cfc600efc2

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
