#
# Copyright (C) 2015-2016, 2018-2020, 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-idna
PKG_VERSION:=3.11
PKG_RELEASE:=1

PYPI_NAME:=idna
PKG_HASH:=795dafcc9c04ed0c1fb032c2aa73654d8e8c5023a7df64a53f39190ada629902

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.md
PKG_MAINTAINER:=

PKG_BUILD_DEPENDS:= \
	python3/host \
	python-setuptools/host \
	python-flit-core/host
HOST_BUILD_DEPENDS:= \
	python3/host \
	python-setuptools/host \
	python-build/host \
	python-installer/host \
	python-flit-core/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-idna
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=IDNA library
  URL:=https://github.com/kjd/idna
  DEPENDS:=+python3-light +python3-codecs
endef

define Package/python3-idna/description
A library to support the Internationalised Domain Names in Applications
(IDNA) protocol as specified in RFC 5891. This version of the protocol
is often referred to as "IDNA2008" and can produce different results
from the earlier standard from 2003.
endef

$(eval $(call Py3Package,python3-idna))
$(eval $(call BuildPackage,python3-idna))
$(eval $(call BuildPackage,python3-idna-src))
$(eval $(call HostBuild))
