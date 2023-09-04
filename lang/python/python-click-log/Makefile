# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-click-log
PKG_VERSION:=0.4.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com> 

PYPI_NAME:=click-log
PKG_HASH:=3970f8570ac54491237bcdb3d8ab5e3eef6c057df29f8c3d1151a51a9c23b975
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-click-log
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/click-contrib/click-log
  TITLE:=Logging integration for Click
  DEPENDS:=+python3-light +python3-logging +python3-click
endef

define Package/python3-click-log/description
  Simple and beautiful logging for click applications
endef

$(eval $(call Py3Package,python3-click-log))
$(eval $(call BuildPackage,python3-click-log))
$(eval $(call BuildPackage,python3-click-log-src))
