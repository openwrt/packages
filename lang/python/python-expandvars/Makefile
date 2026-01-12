#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-expandvars
PKG_VERSION:=1.1.2
PKG_RELEASE:=1

PYPI_NAME:=expandvars
PKG_HASH:=6c5822b7b756a99a356b915dd1267f52ab8a4efaa135963bd7f4bd5d368f71d7

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jean Thomas <jean.thomas@wifirst.fr>

PKG_BUILD_DEPENDS:=python-setuptools/host python-hatchling/host

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:= \
	python3/host \
	python-build/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-expandvars
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Expand system variables Unix style
  URL:=https://github.com/sayanarijit/expandvars/
  DEPENDS:= +python3-light
  BUILDONLY:=1
endef

define Package/python3-expandvars/description
This module is inspired by GNU bash's variable expansion features.
It can be used as an alternative to Python's os.path.expandvars function.
endef

$(eval $(call Py3Package,python3-expandvars))
$(eval $(call BuildPackage,python3-expandvars))
$(eval $(call BuildPackage,python3-expandvars-src))
$(eval $(call HostBuild))
