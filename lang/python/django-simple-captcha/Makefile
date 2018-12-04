#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-simple-captcha
PKG_VERSION:=0.5.9
PKG_RELEASE:=2
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).zip
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/d/${PKG_NAME}
PKG_HASH:=0c30a14f02502119fd1a4d308dd5d2b899d0f4284825a396bbb010afd904754a

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/django-simple-captcha
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Eneas U de Queiroz <cote2004-github@yahoo.com>
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
