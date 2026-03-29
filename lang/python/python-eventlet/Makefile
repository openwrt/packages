#
# Copyright (C) 2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-eventlet
PKG_VERSION:=0.40.4
PKG_RELEASE:=1

PYPI_NAME:=eventlet
PKG_HASH:=69bef712b1be18b4930df6f0c495d2a882bf7b63aa111e7b6eeff461cfcaf26f

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:eventlet:eventlet

PKG_BUILD_DEPENDS:= \
	python3/host \
	python-setuptools/host \
	python-hatch-vcs/host \
	python-hatchling/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-eventlet
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python concurrent networking library
  URL:=https://eventlet.net/
  DEPENDS:= \
	+python3-light \
	+python3-dns \
	+python3-greenlet \
	+python3-email \
	+python3-logging \
	+python3-openssl \
	+python3-urllib
endef

define Package/python3-eventlet/description
  Eventlet is a concurrent networking library for Python that
  allows you to change how you run your code, not how you write it.
endef

$(eval $(call Py3Package,python3-eventlet))
$(eval $(call BuildPackage,python3-eventlet))
$(eval $(call BuildPackage,python3-eventlet-src))
