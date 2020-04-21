#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-simple-captcha
PKG_VERSION:=0.5.12
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/mbi/django-simple-captcha/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=89db73a3883573ad5e22c511948a5500491f9848363174d835a2364750c81a77

PKG_MAINTAINER:=Eneas U de Queiroz <cotequeiroz@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-django-simple-captcha
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Simple Django captcha application
  URL:=https://github.com/mbi/django-simple-captcha
  DEPENDS:= \
	+python3 \
	+python3-six \
	+python3-django1 \
	+python3-pillow \
	+python3-django-ranged-response
endef

define Package/python3-django-simple-captcha/description
  Django Simple Captcha is an extremely simple, yet highly customizable Django
  application to add captcha images to any Django form.
endef

$(eval $(call Py3Package,python3-django-simple-captcha))
$(eval $(call BuildPackage,python3-django-simple-captcha))
$(eval $(call BuildPackage,python3-django-simple-captcha-src))
