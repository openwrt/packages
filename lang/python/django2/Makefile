include $(TOPDIR)/rules.mk

PKG_NAME:=django2
PKG_VERSION:=2.2.4
PKG_RELEASE:=1
PKG_LICENSE:=BSD-3-Clause
PKG_MAINTAINER:=Peter Stadler <peter.stadler@student.uibk.ac.at>

PKG_SOURCE:=Django-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/D/Django/
PKG_HASH:=16a5d54411599780ac9dfe3b9b38f90f785c51259a584e0b24b6f14a7f69aae8

PKG_BUILD_DIR:=$(BUILD_DIR)/django2-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/django2
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=The web framework for perfectionists with deadlines.
  URL:=https://www.djangoproject.com/
  DEPENDS:=+python3-base +python3-distutils +python3-urllib +python3-pytz +python3-logging +python3-cgi +python3-decimal +python3-codecs +sqlparse +python3-sqlite3 +python3-unittest +python3-xml +python3-openssl
  VARIANT:=python3
endef 

define Package/django2/description
  The web framework for perfectionists with deadlines.
endef

define Py3Package/xxx/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/django-admin.py $(1)/usr/bin/
	# fix python exec path
	sed -i 's_#!.*_#!/usr/bin/python3_g' $(1)/usr/bin/django-admin.py
endef

$(eval $(call Py3Package,django2))
$(eval $(call BuildPackage,django2))
