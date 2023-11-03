#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-flit-scm
PKG_VERSION:=1.7.0
PKG_RELEASE:=2

PYPI_NAME:=flit-scm
PYPI_SOURCE_NAME:=flit_scm
PKG_HASH:=961bd6fb24f31bba75333c234145fff88e6de0a90fc0f7e5e7c79deca69f6bb2

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:= \
	python3/host \
	python-build/host \
	python-installer/host \
	python-flit-core/host \
	python-setuptools-scm/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-flit-scm
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=A PEP 518 build backend that uses setuptools_scm and flit
  URL:=https://gitlab.com/WillDaSilva/flit_scm
  DEPENDS:=+python3-light +python3-flit-core +python3-setuptools-scm
  BUILDONLY:=1
endef

define Package/python3-flit-scm/description
A PEP 518 build backend that uses setuptools_scm to generate a version
file from your version control system, then flit_core to build the
package.
endef

$(eval $(call Py3Package,python3-flit-scm))
$(eval $(call BuildPackage,python3-flit-scm))
$(eval $(call BuildPackage,python3-flit-scm-src))
$(eval $(call HostBuild))
