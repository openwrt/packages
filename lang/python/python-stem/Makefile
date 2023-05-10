include $(TOPDIR)/rules.mk

PKG_NAME:=python-stem
PKG_VERSION:=1.8.1
PKG_RELEASE:=2

PYPI_NAME:=stem
PKG_HASH:=81d43a7c668ba9d7bc1103b2e7a911e9d148294b373d27a59ae8da79ef7a3e2f

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
