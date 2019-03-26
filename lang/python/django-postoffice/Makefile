#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-postoffice
PKG_VERSION:=3.1.0
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=django-post_office-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/d/django-post_office
PKG_HASH:=827937a944fe47cea393853069cd9315d080298c8ddb0faf787955d6aa51a030
PKG_BUILD_DIR:=$(BUILD_DIR)/django-post_office-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/django-postoffice
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
  TITLE:=A Django app to monitor and send mail asynchronously, complete with template support.
  URL:=https://github.com/ui/django-postoffice
  DEPENDS:=+python +django +django-jsonfield
endef

define Package/django-postoffice/description
  A Django app to monitor and send mail asynchronously, complete with template support.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/django-postoffice/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,django-postoffice))
