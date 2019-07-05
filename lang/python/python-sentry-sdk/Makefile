#
# Copyright (C) 2015-2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-sentry-sdk
PKG_VERSION:=0.9.5
PKG_RELEASE:=1

PKG_SOURCE:=sentry-sdk-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/s/sentry-sdk/
PKG_HASH:=7c9db0e419fb0fb31c1b1d2ec9247667d2b77bd4f3136119ee6f1464e9b088a4
PKG_BUILD_DIR:=$(BUILD_DIR)/sentry-sdk-$(PKG_VERSION)

PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-sentry-sdk
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python Client for Sentry
  URL:=https://github.com/getsentry/sentry-python
  DEPENDS:= \
	+python3-light \
	+python3-urllib3 \
	+python3-certifi
  VARIANT:=python3
endef

define Package/python3-sentry-sdk/description
  Python Sentry-Python is an SDK for Sentry.
endef

$(eval $(call Py3Package,python3-sentry-sdk))
$(eval $(call BuildPackage,python3-sentry-sdk))
$(eval $(call BuildPackage,python3-sentry-sdk-src))
