include $(TOPDIR)/rules.mk

PKG_NAME:=python-distro
PKG_VERSION:=1.6.0
PKG_RELEASE:=1

PYPI_NAME:=distro
PKG_HASH:=83f5e5a09f9c5f68f60173de572930effbcc0287bb84fdc4426cb4168c088424

PKG_MAINTAINER:=Javier Marcet <javier@marcet.info>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-distro
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Distro - an OS platform information API
  URL:=https://github.com/python-distro/distro
  DEPENDS:=+python3-light +python3-logging
endef

define Package/python3-distro/description
  A much more elaborate, renewed alternative implementation for Python's
  platform.linux_distribution()
endef

$(eval $(call Py3Package,python3-distro))
$(eval $(call BuildPackage,python3-distro))
$(eval $(call BuildPackage,python3-distro-src))
