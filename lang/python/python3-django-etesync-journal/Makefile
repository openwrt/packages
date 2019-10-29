include $(TOPDIR)/rules.mk

PKG_NAME:=django-etesync-journal
PKG_VERSION:=1.0.3
PKG_RELEASE:=1

PYPI_NAME:=django-etesync-journal
PKG_HASH:=a81674fab37913831c93107e3335030b0f8eeef074c0abb202aedc9b61a61bac

PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Peter Stadler <peter.stadler@student.uibk.ac.at>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-django-etesync-journal
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=The server side implementation of the EteSync protocol.
  URL:=https://www.etesync.com/
  DEPENDS:=python3-django +python3-django-restframework +python3-light
  VARIANT:=python3
  MDEPENDS:=python3-django
endef

define Package/python3-django-etesync-journal/description
  The reusable django app that implements the server side of the EteSync protocol.
endef

$(eval $(call Py3Package,python3-django-etesync-journal))
$(eval $(call BuildPackage,python3-django-etesync-journal))
$(eval $(call BuildPackage,python3-django-etesync-journal-src))
