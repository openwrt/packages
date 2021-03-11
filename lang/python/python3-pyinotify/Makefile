#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pyinotify
PKG_VERSION:=0.9.6
PKG_RELEASE:=1
PKGARCH:=ALL

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/pyinotify/
PKG_HASH:=9c998a5d7606ca835065cdabc013ae6c66eb9ea76a00a1e3bc6e0cfe2b4f71f4

PKG_MAINTAINER:=Gerald Kerma <gandalf@gk2.net>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

#include $(TOPDIR)/feeds/packages/lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk

#PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-$(PKG_NAME)-$(PKG_VERSION)
#PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python3-pyinotify
	SUBMENU:=Python
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=Pyinotify is a Python module for monitoring filesystems changes.
	URL:=http://github.com/seb-m/pyinotify
	DEPENDS:= +python3-light
	VARIANT:=python3
endef

define Package/python3-pyinotify/description
Pyinotify is a Python module for monitoring filesystems changes.
endef

$(eval $(call Py3Package,python3-pyinotify))
$(eval $(call BuildPackage,python3-pyinotify))
$(eval $(call BuildPackage,python3-pyinotify-src))
