include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=python-libmodbus
PKG_VERSION:=0.5.0
PKG_RELEASE:=1

PKG_LICENSE:=BSD-3-Clause
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PYPI_NAME:=pylibmodbus
PKG_HASH:=80f837304ffa8476145ea643f6b98aa94b205013a96f1e5173d7bdc776426aee

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-libmodbus/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  URL:=https://pypi.org/project/pylibmodbus
endef

define Package/python-libmodbus
$(call Package/python-libmodbus/Default)
  TITLE:=python-libmodbus
  DEPENDS:=+libmodbus \
     +PACKAGE_python-libmodbus:python-light \
     +PACKAGE_python-libmodbus:python-cffi
  VARIANT:=python
endef

define Package/python3-libmodbus
$(call Package/python-libmodbus/Default)
  TITLE:=pylibmodbus
  DEPENDS:=+libmodbus \
     +PACKAGE_python3-libmodbus:python3-light \
     +PACKAGE_python3-libmodbus:python3-cffi
  VARIANT:=python3
endef

define Package/python-libmodbus/description
	Python Interface for libmodbus written with CFFI.
endef

define Package/python3-libmodbus/description
$(call Package/python-libmodbus/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-libmodbus))
$(eval $(call BuildPackage,python-libmodbus))

$(eval $(call Py3Package,python3-libmodbus))
$(eval $(call BuildPackage,python3-libmodbus))
