include $(TOPDIR)/rules.mk

PKG_NAME:=python-docker
PKG_VERSION:=4.2.0
PKG_RELEASE:=1

PYPI_NAME:=docker
PKG_HASH:=ddae66620ab5f4bce769f64bcd7934f880c8abe6aa50986298db56735d0f722e

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Javier Marcet <javier@marcet.info>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

PYTHON3_PKG_SETUP_ARGS:=

define Package/python3-docker
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=A Python library for the Docker Engine API
  URL:=https://github.com/docker/docker-py
  DEPENDS:=+python3-light +python3-paramiko +python3-setuptools +python3-six
  VARIANT:=python3
endef

define Package/python3-docker/description
  A Python library for the Docker Engine API
endef

$(eval $(call Py3Package,python3-docker))
$(eval $(call BuildPackage,python3-docker))
$(eval $(call BuildPackage,python3-docker-src))
