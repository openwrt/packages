# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pika
PKG_VERSION:=1.4.4
PKG_RELEASE:=1

PYPI_NAME:=pika
PKG_HASH:=8cfc8b33a5cb16e733bd60cffca9732c0d1d761ecd80a89f34ed7df2cd38d6d6

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

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
