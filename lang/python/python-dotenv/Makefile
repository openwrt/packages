include $(TOPDIR)/rules.mk

PKG_NAME:=python-dotenv
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PYPI_NAME:=python-dotenv
PKG_HASH:=a8df96034aae6d2d50a4ebe8216326c61c3eb64836776504fcca410e5937a3ba

PKG_MAINTAINER:=Javier Marcet <javier@marcet.info>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-dotenv
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Add .env support to your django/flask apps in development and deployments
  URL:=http://github.com/theskumar/python-dotenv
  DEPENDS:=+python3-click +python3-light +python3-logging
endef

define Package/python3-dotenv/description
  A Python library which reads the key-value pair from .env file and adds them
  to environment variable. It is great for managing app settings during
  development and in production using 12-factor principles.
endef

$(eval $(call Py3Package,python3-dotenv))
$(eval $(call BuildPackage,python3-dotenv))
$(eval $(call BuildPackage,python3-dotenv-src))
