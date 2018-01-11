#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django
PKG_VERSION:=1.8.18
PKG_RELEASE=1
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/django/django.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=2d4bc5a60aa8a076689667c550ded96b87bc463e
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=c82c2cc338ae46ba8572d9960fc98dca932edc43a00f011fed102810a86185ae

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/django
    SUBMENU:=Python
    SECTION:=lang
    CATEGORY:=Languages
    TITLE:=The web framework for perfectionists with deadlines.
    MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
    URL:=https://www.djangoproject.com/
    DEPENDS:=+python
endef

define Package/django/description
    The web framework for perfectionists with deadlines.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/django-admin.py \
	    $(1)/usr/bin
endef

define Package/django/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/django-admin.py \
	    $(1)/usr/bin
	# fix python exec path
	sed -i 's/#!.*/#!\/usr\/bin\/python/g' $(1)/usr/bin/django-admin.py
endef

$(eval $(call BuildPackage,django))
