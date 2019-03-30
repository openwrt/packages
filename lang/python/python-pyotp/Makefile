#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pyotp
PKG_VERSION:=2.2.7
PKG_RELEASE:=1

PKG_SOURCE:=pyotp-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/pyotp
PKG_HASH:=be0ffeabddaa5ee53e7204e7740da842d070cf69168247a3d0c08541b84de602

PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pyotp
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python One-Time Password Library
  URL:=https://github.com/pyauth/pyotp
  DEPENDS:=+python3-light
  VARIANT:=python3
endef

define Package/python3-pyotp/description
  PyOTP is a Python library for generating and verifying one-time passwords.
  It can be used to implement two-factor (2FA) or multi-factor (MFA) authentication methods
  in web applications and in other systems that require users to log in.
endef

$(eval $(call Py3Package,python3-pyotp))
$(eval $(call BuildPackage,python3-pyotp))
$(eval $(call BuildPackage,python3-pyotp-src))
