#
# Copyright (C) 2022 Julien Malik <julien.malik@paraiso.me>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-trio
PKG_VERSION:=0.22.0
PKG_RELEASE:=1

PYPI_NAME:=trio
PKG_HASH:=ce68f1c5400a47b137c5a4de72c7c901bd4e7a24fbdebfe9b41de8c6c04eaacf

PKG_LICENSE:=Apache-2.0|MIT
PKG_LICENSE_FILES:=LICENSE.APACHE2|LICENSE.MIT
PKG_MAINTAINER:=Julien Malik <julien.malik@paraiso.me>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-trio
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=A friendly Python library for async concurrency and I/O
  URL:=https://trio.readthedocs.io
  DEPENDS:= \
    +python3-light \
    +python3-attrs \
    +python3-async-generator \
    +python3-cffi \
    +python3-exceptiongroup \
    +python3-idna \
    +python3-outcome \
    +python3-sniffio \
    +python3-sortedcontainers
endef

define Package/python3-trio/description
  The Trio project’s goal is to produce a production-quality, permissively licensed, async/await-native I/O library for Python
endef

$(eval $(call Py3Package,python3-trio))
$(eval $(call BuildPackage,python3-trio))
$(eval $(call BuildPackage,python3-trio-src))
