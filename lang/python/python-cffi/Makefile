#
# Copyright (C) 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-cffi
PKG_VERSION:=1.14.6
PKG_RELEASE:=1

PYPI_NAME:=cffi
PKG_HASH:=c9a875ce9d7fe32887784274dd533c57909b7b1dcadcc128a2ac21331a9765dd

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-cffi
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=C Foreign Function Interface
  URL:=https://cffi.readthedocs.org/
  DEPENDS:= \
      +libffi \
      +python3-light \
      +python3-pycparser
endef

define Package/python3-cffi/description
Foreign Function Interface for Python calling C code.
endef

$(eval $(call Py3Package,python3-cffi))
$(eval $(call BuildPackage,python3-cffi))
$(eval $(call BuildPackage,python3-cffi-src))
