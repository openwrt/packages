#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-postoffice
PKG_VERSION:=3.1.0
PKG_RELEASE:=4

PKG_SOURCE:=django-post_office-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/d/django-post_office
PKG_HASH:=827937a944fe47cea393853069cd9315d080298c8ddb0faf787955d6aa51a030

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/$(PKG_NAME)/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=A Django app to monitor and send mail asynchronously
  URL:=https://github.com/ui/django-post_office
endef

define Package/python-$(PKG_NAME)
$(call Package/$(PKG_NAME)/Default)
  DEPENDS:= \
	+PACKAGE_python-$(PKG_NAME):python \
	python-django \
	+PACKAGE_python-$(PKG_NAME):python-django-jsonfield
  VARIANT:=python
  MDEPENDS:=python-django
endef

define Package/python-$(PKG_NAME)/description
  A Django app to monitor and send mail asynchronously, complete with template
  support
endef

define Package/python3-$(PKG_NAME)
$(call Package/$(PKG_NAME)/Default)
  DEPENDS:= \
	+PACKAGE_python3-$(PKG_NAME):python3 \
	python3-django \
	+PACKAGE_python3-$(PKG_NAME):python3-django-jsonfield
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
