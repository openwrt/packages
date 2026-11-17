#
# Copyright (C) 2020 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-iniconfig
PKG_VERSION:=2.3.1
PKG_RELEASE:=1

PYPI_NAME:=iniconfig
PKG_HASH:=67f4b9c50da0dedf52af349e7749a80a9057a5031199791b906c3bb3ae878960

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-hatchling/host python-hatch-vcs/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-iniconfig
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Simple config-ini parser
  URL:=https://github.com/pytest-dev/iniconfig
  DEPENDS:= +python3-light
endef

define Package/python3-iniconfig/description
  iniconfig is a small and simple INI-file parser module.
endef

$(eval $(call Py3Package,python3-iniconfig))
$(eval $(call BuildPackage,python3-iniconfig))
$(eval $(call BuildPackage,python3-iniconfig-src))
