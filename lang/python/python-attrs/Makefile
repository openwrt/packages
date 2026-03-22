#
# Copyright (C) 2016, 2018-2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-attrs
PKG_VERSION:=25.4.0
PKG_RELEASE:=1

PYPI_NAME:=attrs
PKG_HASH:=16d5969b87f0859ef33a48b35d55ac1be6e42ae49d5e853b597db70c35c57e11

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DEPENDS:=python-hatchling/host python-hatch-vcs/host python-hatch-fancy-pypi-readme/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-attrs
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Classes Without Boilerplate
  URL:=https://www.attrs.org/
  DEPENDS:=+python3-light +python3-codecs
endef

define Package/python3-attrs/description
attrs is an MIT-licensed Python package with class decorators that ease
the chores of implementing the most common attribute-related object
protocols.
endef

$(eval $(call Py3Package,python3-attrs))
$(eval $(call BuildPackage,python3-attrs))
$(eval $(call BuildPackage,python3-attrs-src))
