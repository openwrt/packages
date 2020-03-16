#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-ranged-response
PKG_VERSION:=0.2.0
PKG_RELEASE:=7

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=f71fff352a37316b9bead717fc76e4ddd6c9b99c4680cdf4783b9755af1cf985

PKG_MAINTAINER:=Eneas U de Queiroz <cotequeiroz@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/django-ranged-response/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Add Content-Range: to FileResponse
  URL:=https://github.com/i3thuan5/django-ranged-response
endef

define Package/python-django-ranged-response
$(call Package/django-ranged-response/Default)
  DEPENDS:= \
	+PACKAGE_python-django-ranged-response:python \
	python-django1
  VARIANT:=python
  MDEPENDS:=python-django1
endef

define Package/python-django-ranged-response/description
  Modified Django FileResponse that adds Content-Range headers.
endef

define Package/python3-django-ranged-response
$(call Package/django-ranged-response/Default)
  DEPENDS:= \
	+PACKAGE_python3-django-ranged-response:python3 \
	+PACKAGE_python3-django-ranged-response:python3-django1
  VARIANT:=python3
endef

define Package/python3-django-ranged-response/description
$(call Package/python-django-ranged-response/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-django-ranged-response))
$(eval $(call BuildPackage,python-django-ranged-response))
$(eval $(call BuildPackage,python-django-ranged-response-src))

$(eval $(call Py3Package,python3-django-ranged-response))
$(eval $(call BuildPackage,python3-django-ranged-response))
$(eval $(call BuildPackage,python3-django-ranged-response-src))
