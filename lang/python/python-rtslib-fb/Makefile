#
# Copyright (C) 2026 Andreas Hirschauer
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-rtslib-fb
PKG_VERSION:=2.2.4
PKG_RELEASE:=1

PYPI_NAME:=rtslib-fb
PYPI_SOURCE_NAME:=rtslib_fb
PKG_HASH:=0084daa651a72b1cacd0eaaf162725df69b991f501cffe87e0f67e99224a7267

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Andreas Hirschauer <andi@linux.com>
PKG_BUILD_DEPENDS:=python-hatchling/host python-hatch-vcs/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Build/Prepare
	$(call Build/Prepare/Default)
	# Upstream targetctl imports `rtslib_fb`, but sources are in `rtslib/`.
	[ -e "$(PKG_BUILD_DIR)/rtslib_fb" ] || ln -snf rtslib "$(PKG_BUILD_DIR)/rtslib_fb"
endef

define Package/python3-rtslib-fb
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python API for the Linux LIO target subsystem
  URL:=https://github.com/open-iscsi/rtslib-fb
  DEPENDS:=+python3-light +python3-pyudev +python3-uuid +python3-ctypes
endef

define Package/python3-rtslib-fb-src
  TITLE:=rtslib-fb source package
endef

define Package/python3-rtslib-fb/description
 rtslib-fb is a Python object API for configuring the Linux LIO target subsystem.
endef

$(eval $(call Py3Package,python3-rtslib-fb))
$(eval $(call BuildPackage,python3-rtslib-fb))
$(eval $(call BuildPackage,python3-rtslib-fb-src))
