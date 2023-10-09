
include $(TOPDIR)/rules.mk

PKG_NAME:=python-pycares
PKG_VERSION:=4.4.0
PKG_RELEASE:=1

PYPI_NAME:=pycares
PKG_HASH:=f47579d508f2f56eddd16ce72045782ad3b1b3b678098699e2b6a1b30733e1c2

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
