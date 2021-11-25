#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-webpack-loader
PKG_VERSION:=0.7.0
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=7a3c88201aa54481f9399465615cbe7b9aece8081496a6d0287b7cb8e232f447

PKG_MAINTAINER:=Eneas U de Queiroz <cotequeiroz@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-django-webpack-loader
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Transparently use webpack in django
  URL:=https://github.com/owais/django-webpack-loader
  DEPENDS:= \
	@BROKEN \
	+python3 \
	+python3-django1
endef

define Package/python3-django-webpack-loader/description
  Use webpack to generate your static bundles without django’s staticfiles or opaque wrappers.
endef

$(eval $(call Py3Package,python3-django-webpack-loader))
$(eval $(call BuildPackage,python3-django-webpack-loader))
$(eval $(call BuildPackage,python3-django-webpack-loader-src))
