include $(TOPDIR)/rules.mk

PKG_NAME:=python-distro
PKG_VERSION:=1.7.0
PKG_RELEASE:=1

PYPI_NAME:=distro
PKG_HASH:=151aeccf60c216402932b52e40ee477a939f8d58898927378a02abbe852c1c39

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
