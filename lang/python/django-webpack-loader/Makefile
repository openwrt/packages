#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-webpack-loader
PKG_VERSION:=0.6.0
PKG_RELEASE:=7

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=60bab6b9a037a5346fad12d2a70a6bc046afb33154cf75ed640b93d3ebd5f520

PKG_MAINTAINER:=Eneas U de Queiroz <cotequeiroz@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/django-webpack-loader/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Transparently use webpack in django
  URL:=https://github.com/owais/django-webpack-loader
endef

define Package/python-django-webpack-loader
$(call Package/django-webpack-loader/Default)
  DEPENDS:= \
	+PACKAGE_python-django-webpack-loader:python \
	python-django1
  VARIANT:=python
  MDEPENDS:=python-django1
endef

define Package/python-django-webpack-loader/description
  Use webpack to generate your static bundles without django’s staticfiles or opaque wrappers.
endef

define Package/python3-django-webpack-loader
$(call Package/django-webpack-loader/Default)
  DEPENDS:= \
	+PACKAGE_python3-django-webpack-loader:python3 \
	+PACKAGE_python3-django-webpack-loader:python3-django1
  VARIANT:=python3
endef

define Package/python3-django-webpack-loader/description
$(call Package/python-django-webpack-loader/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-django-webpack-loader))
$(eval $(call BuildPackage,python-django-webpack-loader))
$(eval $(call BuildPackage,python-django-webpack-loader-src))

$(eval $(call Py3Package,python3-django-webpack-loader))
$(eval $(call BuildPackage,python3-django-webpack-loader))
$(eval $(call BuildPackage,python3-django-webpack-loader-src))
