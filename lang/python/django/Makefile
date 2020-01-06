#
# Copyright (C) Alexandru Ardelean <ardeleanalex@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django
PKG_VERSION:=3.0.2
PKG_RELEASE:=1

PYPI_NAME:=Django
PKG_HASH:=8c3575f81e11390893860d97e1e0154c47512f180ea55bd84ce8fa69ba8051ca

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE LICENSE.python
PKG_CPE_ID:=cpe:/a:djangoproject:django

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/django/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=The web framework for perfectionists with deadlines.
  URL:=https://www.djangoproject.com/
  MENU:=1
endef

define Package/python3-django
$(call Package/django/Default)
  DEPENDS:= +python3 +python3-pytz +python3-sqlparse
  VARIANT:=python3
endef

define Package/python3-django/description
    The web framework for perfectionists with deadlines (LTS 2.2 series).
    Python3 only.
endef

define Py3Package/python3-django/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/django-admin.py \
		$(1)/usr/bin/django-admin
endef

$(eval $(call Py3Package,python3-django))
$(eval $(call BuildPackage,python3-django))
$(eval $(call BuildPackage,python3-django-src))
