#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-tomli
PKG_VERSION:=2.0.1
PKG_RELEASE:=1

PYPI_NAME:=tomli
PKG_HASH:=de526c12914f0c550d15924c62d72abc48d6fe7364aa87328337a31007fe8a4f

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:=python3/host python-flit-core/host python-installer/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-tomli
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=A lil' TOML parser
  URL:=https://github.com/hukkin/tomli
  DEPENDS:=+python3-light
  BUILDONLY:=1
endef

define Package/python3-tomli/description
Tomli is a Python library for parsing TOML. Tomli is fully compatible
with TOML v1.0.0.
endef

Host/Compile=$(Py3Host/Compile/Bootstrap)

$(eval $(call Py3Package,python3-tomli))
$(eval $(call BuildPackage,python3-tomli))
$(eval $(call BuildPackage,python3-tomli-src))
$(eval $(call HostBuild))
