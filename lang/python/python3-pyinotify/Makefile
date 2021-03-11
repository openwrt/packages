#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python3-pyinotify
PKG_VERSION:=0.9.6
PKG_RELEASE:=1

PYPI_NAME:=pyinotify
PKG_HASH:=9c998a5d7606ca835065cdabc013ae6c66eb9ea76a00a1e3bc6e0cfe2b4f71f4

PKG_MAINTAINER:=Gerald Kerma <gandalf@gk2.net>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pyinotify
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Linux filesystem events monitoring
  URL:=https://github.com/seb-m/pyinotify
  DEPENDS:= +python3-light \
  +python3-ctypes \
  +python3-logging
endef

define Package/python3-pyinotify/description
  Pyinotify is a Python module for monitoring filesystems changes.
endef

$(eval $(call Py3Package,python3-pyinotify))
$(eval $(call BuildPackage,python3-pyinotify))
$(eval $(call BuildPackage,python3-pyinotify-src))
