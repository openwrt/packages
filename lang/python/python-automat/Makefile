#
# Copyright (C) 2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-automat
PKG_VERSION:=0.6.0
PKG_RELEASE:=1

PKG_SOURCE:=Automat-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/A/Automat
PKG_HASH:=3c1fd04ecf08ac87b4dd3feae409542e9bf7827257097b2b6ed5692f69d6f6a8

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-automat-$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-automat/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/glyph/Automat
endef

define Package/python-automat
$(call Package/python-automat/Default)
  TITLE:=Concise, idiomatic finite-state automata
  DEPENDS:= \
      +PACKAGE_python-automat:python-light \
      +PACKAGE_python-automat:python-attrs \
      +PACKAGE_python-automat:python-six
  VARIANT:=python
endef

define Package/python3-automat
$(call Package/python-automat/Default)
  TITLE:=Concise, idiomatic finite-state automata
  DEPENDS:= \
      +PACKAGE_python3-automat:python3-light \
      +PACKAGE_python3-automat:python3-attrs \
      +PACKAGE_python3-automat:python3-six
  VARIANT:=python3
endef

define Package/python-automat/description
Automat is a library for concise, idiomatic Python expression of
finite-state automata (particularly deterministic finite-state
transducers).
endef

define Package/python3-automat/description
$(call Package/python-automat/description)
.
(Variant for Python3)
endef

define PyPackage/python-automat/filespec
+|$(PYTHON_PKG_DIR)
-|$(PYTHON_PKG_DIR)/automat/_visualize.py
endef

define Py3Package/python3-automat/filespec
+|$(PYTHON3_PKG_DIR)
-|$(PYTHON3_PKG_DIR)/automat/_visualize.py
endef

define PyBuild/Compile
	$(call Build/Compile/PyMod,, \
		install --prefix="/usr" --root="$(PKG_INSTALL_DIR)", \
		PKG_VERSION="$(PKG_VERSION)" \
	)
endef

define Py3Build/Compile
	$(call Build/Compile/Py3Mod,, \
		install --prefix="/usr" --root="$(PKG_INSTALL_DIR)", \
		PKG_VERSION="$(PKG_VERSION)" \
	)
endef

$(eval $(call PyPackage,python-automat))
$(eval $(call BuildPackage,python-automat))
$(eval $(call BuildPackage,python-automat-src))

$(eval $(call Py3Package,python3-automat))
$(eval $(call BuildPackage,python3-automat))
$(eval $(call BuildPackage,python3-automat-src))
