#
# Copyright (C) 2007-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-statici18n
PKG_VERSION:=1.8.2
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/d/django-statici18n
PKG_HASH:=ba9eeb3c4517027922645999359f8335fbb9fea04c457123cfbd6b4a36cbeda4

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
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
  TITLE:=Helper for generating JavaScript catalog to static files
  URL:=https://$(PKG_NAME).readthedocs.io
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
  A Django app that provides helper for generating JavaScript catalog to static files.
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
