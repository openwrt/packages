#
# Copyright (C) 2015-2016, 2018-2020, 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-gmpy2
PKG_VERSION:=2.2.2
PKG_RELEASE:=1

PYPI_NAME:=gmpy2
PKG_HASH:=d9b8c81e0f5e1a3cabf1ea8d154b29b5ef6e33b8f4e4c37b3da957b2dd6a3fa8

PKG_LICENSE:=LGPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING.LESSER
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_BUILD_DEPENDS:= \
	python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-gmpy2
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=GMP/MPIR, MPFR, and MPC interface
  URL:=https://github.com/aleaxit/gmpy
  DEPENDS:=+libgmp +libmpc +libmpfr +python3-light
endef

define Package/python3-gmpy2/description
gmpy2 is a C-coded Python extension module that supports multiple-precision
arithmetic. gmpy2 is the successor to the original gmpy module. The gmpy module
only supported the GMP multiple-precision library. gmpy2 adds support for the
MPFR (correctly rounded real floating-point arithmetic) and MPC (correctly
rounded complex floating-point arithmetic) libraries. gmpy2 also updates the
API and naming conventions to be more consistent and support the additional
functionality.
endef

$(eval $(call Py3Package,python3-gmpy2))
$(eval $(call BuildPackage,python3-gmpy2))
$(eval $(call BuildPackage,python3-gmpy2-src))
