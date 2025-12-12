#
# Copyright (C) 2020-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-psutil
PKG_VERSION:=5.9.5
PKG_RELEASE:=1

PYPI_NAME:=psutil
PKG_HASH:=5410638e4df39c54d957fc51ce03048acd8e6d60abc0f5107af51e5fb566eb3c

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:psutil_project:psutil

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-psutil
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Process and system monitoring
  URL:=https://github.com/giampaolo/psutil
  DEPENDS:=+python3-light
endef

define Package/python3-psutil/description
  psutil is a cross-platform library for retrieving information
  on running processes and system utilization.
endef

$(eval $(call Py3Package,python3-psutil))
$(eval $(call BuildPackage,python3-psutil))
$(eval $(call BuildPackage,python3-psutil-src))
