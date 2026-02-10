#
# Copyright (C) 2022 Julien Malik <julien.malik@paraiso.me>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-sniffio
PKG_VERSION:=1.3.0
PKG_RELEASE:=2

PYPI_NAME:=sniffio
PKG_HASH:=e60305c5e5d314f5389259b7f22aaa33d8f7dee49763119234af3755c55b9101

PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=LICENSE.APACHE2 LICENSE.MIT
PKG_MAINTAINER:=Julien Malik <julien.malik@paraiso.me>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-sniffio
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Sniff out which async library your code is running under
  URL:=https://sniffio.readthedocs.io
  DEPENDS:=+python3-light
endef

define Package/python3-sniffio/description
  This is a tiny package whose only purpose is to let you detect which async library your code is running under.
endef

$(eval $(call Py3Package,python3-sniffio))
$(eval $(call BuildPackage,python3-sniffio))
$(eval $(call BuildPackage,python3-sniffio-src))
