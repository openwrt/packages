#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-webpack-loader
PKG_VERSION:=0.6.0
PKG_RELEASE:=5

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/d/${PKG_NAME}
PKG_HASH:=60bab6b9a037a5346fad12d2a70a6bc046afb33154cf75ed640b93d3ebd5f520

PKG_MAINTAINER:=Eneas U de Queiroz <cotequeiroz@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/$(PKG_NAME)/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Transparently use webpack in django
  URL:=https://github.com/owais/django-webpack-loader
endef

define Package/python-$(PKG_NAME)
$(call Package/$(PKG_NAME)/Default)
  DEPENDS:= \
	+PACKAGE_python-$(PKG_NAME):python \
	python-django
  VARIANT:=python
  MDEPENDS:=python-django
endef

define Package/python-$(PKG_NAME)/description
  Use webpack to generate your static bundles without django’s staticfiles or opaque wrappers.
endef

define Package/python3-$(PKG_NAME)
$(call Package/$(PKG_NAME)/Default)
  DEPENDS:= \
	+PACKAGE_python3-$(PKG_NAME):python3 \
	python3-django
  VARIANT:=python3
  MDEPENDS:=python3-django
endef

define Package/python3-$(PKG_NAME)/description
$(call define Package/python-$(PKG_NAME)/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-$(PKG_NAME)))
$(eval $(call BuildPackage,python-$(PKG_NAME)))
$(eval $(call BuildPackage,python-$(PKG_NAME)-src))

$(eval $(call Py3Package,python3-$(PKG_NAME)))
$(eval $(call BuildPackage,python3-$(PKG_NAME)))
$(eval $(call BuildPackage,python3-$(PKG_NAME)-src))
