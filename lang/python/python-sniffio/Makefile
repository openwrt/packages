#
# Copyright (C) 2022 Julien Malik <julien.malik@paraiso.me>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-sniffio
PKG_VERSION:=1.3.1
PKG_RELEASE:=1

PYPI_NAME:=sniffio
PKG_HASH:=f4324edc670a0f49750a81b895f35c3adb843cca46f0530f79fc1babb23789dc

PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=LICENSE.APACHE2 LICENSE.MIT
PKG_MAINTAINER:=Julien Malik <julien.malik@paraiso.me>
PKG_BUILD_DEPENDS:=python-setuptools/host python-setuptools-scm/host

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
