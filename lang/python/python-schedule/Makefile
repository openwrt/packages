#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-schedule
PKG_VERSION:=1.2.0
PKG_RELEASE:=1

PYPI_NAME:=schedule
PKG_HASH:=b4ad697aafba7184c9eb6a1e2ebc41f781547242acde8ceae9a0a25b04c0922d

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-schedule
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Job scheduling for humans
  URL:=https://github.com/dbader/schedule
  DEPENDS:=+python3-light +python3-logging
endef

define Package/python3-schedule/description
An in-process scheduler for periodic jobs that uses the builder pattern
for configuration. The Schedule lets you run Python functions (or any
other callable) periodically at predetermined intervals using a simple,
human-friendly syntax.
endef

$(eval $(call Py3Package,python3-schedule))
$(eval $(call BuildPackage,python3-schedule))
$(eval $(call BuildPackage,python3-schedule-src))
