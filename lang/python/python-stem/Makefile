include $(TOPDIR)/rules.mk

PKG_NAME:=python-stem
PKG_VERSION:=1.8.2
PKG_RELEASE:=1

PYPI_NAME:=stem
PKG_HASH:=83fb19ffd4c9f82207c006051480389f80af221a7e4783000aedec4e384eb582

PKG_MAINTAINER:=Javier Marcet <javier@marcet.info>
PKG_LICENSE:=LGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-stem
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=A controller library for Tor
  URL:=https://stem.torproject.org/
  DEPENDS:=+python3
endef

define Package/python3-stem/description
  Stem is a Python controller library for Tor. With it you can use Tor's control
  protocol to script against the Tor process, or build things such as Nyx.
endef

$(eval $(call Py3Package,python3-stem))
$(eval $(call BuildPackage,python3-stem))
$(eval $(call BuildPackage,python3-stem-src))
