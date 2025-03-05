
include $(TOPDIR)/rules.mk

PKG_NAME:=python-pycares
PKG_VERSION:=4.5.0
PKG_RELEASE:=1

PYPI_NAME:=pycares
PKG_HASH:=025b6c2ffea4e9fb8f9a097381c2fecb24aff23fbd6906e70da22ec9ba60e19d

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Fabian Lipken <dynasticorpheus@gmail.com>

PKG_BUILD_DEPENDS:=libffi/host python-cffi/host  # cffi>=1.5.0

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pycares
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python interface for c-ares
  URL:=https://github.com/saghul/pycares
  DEPENDS:=+python3-light +python3-cffi
endef

define Package/python3-pycares/description
Python interface for c-ares
endef

$(eval $(call Py3Package,python3-pycares))
$(eval $(call BuildPackage,python3-pycares))
$(eval $(call BuildPackage,python3-pycares-src))
