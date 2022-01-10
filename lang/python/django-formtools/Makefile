#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-formtools
PKG_VERSION:=2.2
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=c5272c03c1cd51b2375abf7397a199a3148a9fbbf2f100e186467a84025d13b2

PKG_MAINTAINER:=Eneas U de Queiroz <cotequeiroz@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-django-formtools
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=High-level abstractions for Django forms
  URL:=https://django-formtools.readthedocs.io
  DEPENDS:= \
	@BROKEN \
	+python3 \
	+python3-django1
endef

define Package/python3-django-formtools/description
  Django "formtools" is a set of high-level abstractions for Django forms.
  Currently for form previews and multi-step forms.
endef

$(eval $(call Py3Package,python3-django-formtools))
$(eval $(call BuildPackage,python3-django-formtools))
$(eval $(call BuildPackage,python3-django-formtools-src))
