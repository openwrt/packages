include $(TOPDIR)/rules.mk

PKG_NAME:=django-etesync-journal
PKG_VERSION:=1.2.0
PKG_RELEASE:=2

PYPI_NAME:=django-etesync-journal
PKG_HASH:=1b481f592217186482be9faee686f0c132790db4177deb1f5152b73e99ac6338

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
  DEPENDS:=+django +python3-django-restframework +python3-light
  VARIANT:=python3
endef

define Package/python3-django-etesync-journal/description
  The reusable django app that implements the server side of the EteSync protocol.
endef

$(eval $(call Py3Package,python3-django-etesync-journal))
$(eval $(call BuildPackage,python3-django-etesync-journal))
$(eval $(call BuildPackage,python3-django-etesync-journal-src))
