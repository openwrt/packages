#
# Copyright (C) 2019-2020 CZ.NIC z.s.p.o. (http://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-wcwidth
PKG_VERSION:=0.1.8
PKG_RELEASE:=1

PYPI_NAME:=wcwidth
PKG_HASH:=f28b3e8a6483e5d49e7f8949ac1a78314e740333ae305b4ba5defd3e74fb37a8

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-wcwidth
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Terminal width calculation library
  URL:=https://github.com/jquast/wcwidth
  DEPENDS:=+python3-light
  VARIANT:=python3
endef

define Package/python3-wcwidth/description
  Python library that measures the width of unicode strings rendered to a terminal
endef

$(eval $(call Py3Package,python3-wcwidth))
$(eval $(call BuildPackage,python3-wcwidth))
$(eval $(call BuildPackage,python3-wcwidth-src))
