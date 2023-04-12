include $(TOPDIR)/rules.mk

PKG_NAME:=python-makeelf
PKG_VERSION:=0.3.4
PKG_RELEASE:=1

PYPI_NAME:=makeelf
PKG_HASH:=9d8b8cf16b00116ea72d96f9f9561c0f960bedc78e68743e2459f1f1d71e0572

PKG_MAINTAINER:=Adam Jovanovic <<adamjovanovic97@gmail.com>>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PYTHON3_PKG_SETUP_ARGS=

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-makeelf
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=A Python library for parsing and creating ELFs
  URL:=https://github.com/v3l0c1r4pt0r/makeelf
endef

define Package/python3-makeelf/description
  ELF reader-writer library
endef

$(eval $(call Py3Package,python3-makeelf))
$(eval $(call BuildPackage,python3-makeelf))
$(eval $(call BuildPackage,python3-makeelf-src))