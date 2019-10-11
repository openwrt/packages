#
# Copyright (C) Alexandru Ardelean <ardeleanalex@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django1
PKG_VERSION:=1.11.24
PKG_RELEASE:=1

PKG_SOURCE:=Django-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/D/Django
PKG_HASH:=215c27453f775b6b1add83a185f76c2e2ab711d17786a6704bd62eabd93f89e3
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-django-$(PKG_VERSION)

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE LICENSE.python
PKG_CPE_ID:=cpe:/a:djangoproject:django

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/django1/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=The web framework for perfectionists with deadlines.
  URL:=https://www.djangoproject.com/
  MENU:=1
endef

define Package/python-django1
$(call Package/django1/Default)
  DEPENDS:= \
	+PACKAGE_python-django1:python \
	+PACKAGE_python-django1:python-pytz
  VARIANT:=python
  CONFLICTS:=python3-django
endef

define Package/python-django1/description
    The web framework for perfectionists with deadlines (LTS 1.11 series).
    Python2 only.
endef

$(eval $(call PyPackage,python-django1))
define Package/python-django1-src +=

  MDEPENDS:=python-django1
endef
$(eval $(call BuildPackage,python-django1))
$(eval $(call BuildPackage,python-django1-src))
