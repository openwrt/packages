#
# Copyright (C) 2020 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-toml
PKG_VERSION:=0.10.1
PKG_RELEASE:=1

PYPI_NAME:=toml
PKG_HASH:=926b612be1e5ce0634a2ca03470f95169cf16f939018233a670519cb4ac58b0f

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-toml
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=A Python library for parsing and creating TOML
  URL:=https://github.com/uiri/toml
  DEPENDS:= +python3-light +python3-decimal
endef

define Package/python3-toml/description
  Python Library for Tom's Obvious, Minimal Language
endef

$(eval $(call Py3Package,python3-toml))
$(eval $(call BuildPackage,python3-toml))
$(eval $(call BuildPackage,python3-toml-src))
