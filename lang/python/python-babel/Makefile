#
# Copyright (C) 2019-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-babel
PKG_VERSION:=2.12.1
PKG_RELEASE:=1

PYPI_NAME:=Babel
PKG_HASH:=cc2d99999cd01d44420ae725a21c9e3711b3aadc7976d6147f622d8581963455

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

HOST_BUILD_DEPENDS:=python3/host python-build/host python-installer/host python-wheel/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-babel
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Internationalization utilities
  URL:=https://babel.pocoo.org/
  DEPENDS:= \
    +python3-decimal \
    +python3-distutils \
    +python3-email \
    +python3-light \
    +python3-logging \
    +python3-urllib
endef

define Package/python3-babel/description
  Babel is an integrated collection of utilities that assist in
  internationalizing and localizing Python applications
  with an emphasis on web-based applications.
endef

$(eval $(call Py3Package,python3-babel))
$(eval $(call BuildPackage,python3-babel))
$(eval $(call BuildPackage,python3-babel-src))
$(eval $(call HostBuild))
