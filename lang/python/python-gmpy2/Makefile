#
# Copyright (C) 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-gmpy2
PKG_VERSION:=2.0.8
PKG_RELEASE:=2

PKG_SOURCE:=gmpy2-$(PKG_VERSION).zip
PKG_SOURCE_URL:=https://pypi.python.org/packages/90/f4/9a2e384b325b69bc5827b9a6510a8fb4a51698c915c06a3f25a86458892a
PKG_HASH:=dd233e3288b90f21b0bb384bcc7a7e73557bb112ccf0032ad52aa614eb373d3f

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-gmpy2-$(PKG_VERSION)

PKG_LICENSE:=LGPL-3.0+
PKG_LICENSE_FILES:=COPYING.LESSER
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=unzip -q -d $(PKG_BUILD_DIR) $(DL_DIR)/$(PKG_SOURCE); mv -f $(PKG_BUILD_DIR)/gmpy2-$(PKG_VERSION)/* $(PKG_BUILD_DIR)

define Package/python-gmpy2/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=http://code.google.com/p/gmpy/
endef

define Package/python-gmpy2
$(call Package/python-gmpy2/Default)
  TITLE:=python-gmpy2
  DEPENDS:=+libgmp +PACKAGE_python-gmpy2:python-light
  VARIANT:=python
endef

define Package/python3-gmpy2
$(call Package/python-gmpy2/Default)
  TITLE:=python3-gmpy2
  DEPENDS:=+libgmp +PACKAGE_python3-gmpy2:python3-light
  VARIANT:=python3
endef

define Package/python-gmpy2/description
gmpy2 is a C-coded Python extension module that supports multiple-precision
arithmetic. gmpy2 is the successor to the original gmpy module. The gmpy module
only supported the GMP multiple-precision library. gmpy2 adds support for the
MPFR (correctly rounded real floating-point arithmetic) and MPC (correctly
rounded complex floating-point arithmetic) libraries. gmpy2 also updates the
API and naming conventions to be more consistent and support the additional
functionality.
endef

define Package/python3-gmpy2/description
$(call Package/python-gmpy2/description)
.
(Variant for Python3)
endef

define PyBuild/Compile
	$(call Build/Compile/PyMod,,install --prefix="/usr" --root="$(PKG_INSTALL_DIR)" --nompfr)
endef

define Py3Build/Compile
	$(call Build/Compile/Py3Mod,,install --prefix="/usr" --root="$(PKG_INSTALL_DIR)" --nompfr)
endef

$(eval $(call PyPackage,python-gmpy2))
$(eval $(call BuildPackage,python-gmpy2))

$(eval $(call Py3Package,python3-gmpy2))
$(eval $(call BuildPackage,python3-gmpy2))
