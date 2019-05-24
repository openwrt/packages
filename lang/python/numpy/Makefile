#
# Copyright (C) 2019 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=numpy
PKG_VERSION:=1.16.3
PKG_RELEASE:=1

PKG_SOURCE:=numpy-$(PKG_VERSION).zip
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/93/48/956b9dcdddfcedb1705839280e02cbfeb2861ed5d7f59241210530867d5b/
PKG_HASH:=78a6f89da87eeb48014ec652a65c4ffde370c036d780a995edaeb121d3625621

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-numpy-$(PKG_VERSION)/numpy-$(PKG_VERSION)

PKG_LICENSE:=BSD License
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=unzip -d $(BUILD_DIR)/$(BUILD_VARIANT)-numpy-$(PKG_VERSION) $(DL_DIR)/$(PKG_SOURCE)

define Package/python-numpy/Default
  SECTION:=lang-python
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://www.numpy.org/
endef

define Package/python-numpy
$(call Package/python-numpy/Default)
  TITLE:=python-numpy
  DEPENDS:=+@INSTALL_GFORTRAN +libgfortran +PACKAGE_python-numpy:python
  VARIANT:=python
endef

define Package/python3-numpy
$(call Package/python-numpy/Default)
  TITLE:=python3-numpy
  DEPENDS:=+@INSTALL_GFORTRAN +libgfortran +PACKAGE_python3-numpy:python3
  VARIANT:=python3
endef

define Package/python-numpy/description
NumPy is the fundamental package for array computing with Python.
endef

define Package/python3-numpy/description
$(call Package/python-numpy/description)
.
(Variant for Python3)
endef

define PyBuild/Compile
	$(call Build/Compile/PyMod,,\
		install --prefix=/usr --root=$(PKG_INSTALL_DIR),\
	)
endef

define Py3Build/Compile
	$(call Build/Compile/Py3Mod,,\
		install --prefix=/usr --root=$(PKG_INSTALL_DIR),\
	)
endef

$(eval $(call PyPackage,python-numpy))
$(eval $(call BuildPackage,python-numpy))
$(eval $(call BuildPackage,python-numpy-src))

$(eval $(call Py3Package,python3-numpy))
$(eval $(call BuildPackage,python3-numpy))
$(eval $(call BuildPackage,python3-numpy-src))
