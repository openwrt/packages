# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-tabulate
PKG_VERSION:=0.10.0
PKG_RELEASE:=1

PYPI_NAME:=tabulate
PKG_HASH:=e2cfde8f79420f6deeffdeda9aaec3b6bc5abce947655d17ac662b126e48a60d

PKG_MAINTAINER:=Austin Lane <vidplace7@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-setuptools-scm/host
HOST_BUILD_DEPENDS:= \
	python3/host \
	python-build/host \
	python-installer/host \
	python-wheel/host \
	python-setuptools-scm/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-tabulate
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Pretty-print tabular data
  URL:=https://pypi.org/project/tabulate
  DEPENDS:=+python3-light
endef

define Package/python3-tabulate/description
Pretty-print tabular data
endef

$(eval $(call Py3Package,python3-tabulate))
$(eval $(call BuildPackage,python3-tabulate))
$(eval $(call BuildPackage,python3-tabulate-src))
$(eval $(call HostBuild))
