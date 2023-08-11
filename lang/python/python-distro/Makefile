include $(TOPDIR)/rules.mk

PKG_NAME:=python-distro
PKG_VERSION:=1.8.0
PKG_RELEASE:=1

PYPI_NAME:=distro
PKG_HASH:=02e111d1dc6a50abb8eed6bf31c3e48ed8b0830d1ea2a1b78c61765c2513fdd8

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
  TITLE:=OS platform information API
  URL:=https://github.com/python-distro/distro
  DEPENDS:=+python3-light +python3-logging
endef

define Package/python3-distro/description
distro provides information about the OS distribution it runs on, such
as a reliable machine-readable ID, or version information.
endef

$(eval $(call Py3Package,python3-distro))
$(eval $(call BuildPackage,python3-distro))
$(eval $(call BuildPackage,python3-distro-src))
