include $(TOPDIR)/rules.mk

PKG_NAME:=python-distro
PKG_VERSION:=1.9.0
PKG_RELEASE:=1

PYPI_NAME:=distro
PKG_HASH:=2fa77c6fd8940f116ee1d6b94a2f90b13b5ea8d019b98bc8bafdcabcdd9bdbed

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
