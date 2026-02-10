#
# Copyright (C) 2022 Julien Malik <julien.malik@paraiso.me>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-outcome
PKG_VERSION:=1.2.0
PKG_RELEASE:=2

PYPI_NAME:=outcome
PKG_HASH:=6f82bd3de45da303cf1f771ecafa1633750a358436a8bb60e06a1ceb745d2672

PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=LICENSE.APACHE2 LICENSE.MIT
PKG_MAINTAINER:=Julien Malik <julien.malik@paraiso.me>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-outcome
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Capture the outcome of Python function calls.
  URL:=https://outcome.readthedocs.io
  DEPENDS:= \
    +python3-light \
    +python3-attrs
endef

define Package/python3-outcome/description
  Capture the outcome of Python function calls. Extracted from the Trio project.
endef

$(eval $(call Py3Package,python3-outcome))
$(eval $(call BuildPackage,python3-outcome))
$(eval $(call BuildPackage,python3-outcome-src))
