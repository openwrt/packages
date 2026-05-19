# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyelftools
PKG_VERSION:=0.32
PKG_RELEASE:=1

PYPI_NAME:=pyelftools
PKG_HASH:=6de90ee7b8263e740c8715a925382d4099b354f29ac48ea40d840cf7aa14ace5

PKG_MAINTAINER:=Austin Lane <vidplace7@gmail.com>
PKG_LICENSE:=Unlicense
PKG_LICENSE_FILES:=LICENSE

HOST_BUILD_DEPENDS:= \
	python3/host \
	python-build/host \
	python-installer/host \
	python-wheel/host \
	python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-pyelftools
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Library for analyzing ELF files and DWARF debugging information
  URL:=https://pypi.org/project/pyelftools
  DEPENDS:=+python3-light +python3-logging
endef

define Package/python3-pyelftools/description
Library for analyzing ELF files and DWARF debugging information
endef

$(eval $(call Py3Package,python3-pyelftools))
$(eval $(call BuildPackage,python3-pyelftools))
$(eval $(call BuildPackage,python3-pyelftools-src))
$(eval $(call HostBuild))
