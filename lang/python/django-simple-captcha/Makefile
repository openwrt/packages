#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-simple-captcha
PKG_VERSION:=0.5.11
PKG_RELEASE:=1

PKG_MAINTAINER:=Eneas U de Queiroz <cote2004-github@yahoo.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).zip
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/d/$(PKG_NAME)
PKG_HASH:=e14e5c4b207be3dffb200309e7ac7a48de1a2b3293f09eefedd9ab317c4d9a7f

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/django-simple-captcha
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=A very simple, yet powerful, Django captcha application
  URL:=https://github.com/mbi/django-simple-captcha
  DEPENDS:=+python +python-six +django +pillow +django-ranged-response
  VARIANT:=python
endef

define Package/django-simple-captcha/description
  Django Simple Captcha is an extremely simple, yet highly customizable Django
  application to add captcha images to any Django form.
endef

$(eval $(call PyPackage,django-simple-captcha))
$(eval $(call BuildPackage,django-simple-captcha))
$(eval $(call BuildPackage,django-simple-captcha-src))
