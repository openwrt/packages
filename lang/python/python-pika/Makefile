# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pika
PKG_VERSION:=1.3.2
PKG_RELEASE:=1

PYPI_NAME:=pika
PKG_HASH:=b2a327ddddf8570b4965b3576ac77091b850262d34ce8c1d8cb4e4146aa4145f

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=

PKG_BUILD_DEPENDS:=python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pika
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Pika RabbitMQ/AMQP 0-9-1 client library
  URL:=https://pika.readthedocs.io/
  DEPENDS:=+python3
endef

define Package/python3-pika/description
  Pika is a pure-Python implementation of the AMQP 0-9-1 protocol including
  RabbitMQ's extensions.
endef

$(eval $(call Py3Package,python3-pika))
$(eval $(call BuildPackage,python3-pika))
$(eval $(call BuildPackage,python3-pika-src))
