include $(TOPDIR)/rules.mk

PKG_NAME:=python-texttable
PKG_VERSION:=1.6.2
PKG_RELEASE:=2

PYPI_NAME:=texttable
PKG_HASH:=eff3703781fbc7750125f50e10f001195174f13825a92a45e9403037d539b4f4

PKG_MAINTAINER:=Javier Marcet <javier@marcet.info>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-texttable
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Module for creating simple ASCII tables
  URL:=https://github.com/foutaise/texttable/
  DEPENDS:=+python3-light +python3-codecs
endef

define Package/python3-texttable/description
  Module for creating simple ASCII tables
endef

$(eval $(call Py3Package,python3-texttable))
$(eval $(call BuildPackage,python3-texttable))
$(eval $(call BuildPackage,python3-texttable-src))
