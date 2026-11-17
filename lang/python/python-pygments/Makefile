# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pygments
PKG_VERSION:=2.20.0
PKG_RELEASE:=2

PYPI_NAME:=pygments
PKG_HASH:=6757cd03768053ff99f3039c1a36d6c0aa0b263438fcab17520b30a303a82b5f

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:pygments:pygments

PKG_BUILD_DEPENDS:=python-hatchling/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pygments
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Pygments syntax highlighter
  URL:=https://pygments.org/
  DEPENDS:=+python3-light +python3-urllib
endef

define Package/python3-pygments/description
  Pygments is a syntax highlighting library written in Python.
  It supports over 500 languages and text formats.
endef

$(eval $(call Py3Package,python3-pygments))
$(eval $(call BuildPackage,python3-pygments))
$(eval $(call BuildPackage,python3-pygments-src))
