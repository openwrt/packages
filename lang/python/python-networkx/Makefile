#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-networkx
PKG_VERSION:=3.1
PKG_RELEASE:=1

PYPI_NAME:=networkx
PKG_HASH:=de346335408f84de0eada6ff9fafafff9bcda11f0a0dfaa931133debb146ab61

PKG_LICENSE:=BSD-3-clause
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-networkx
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Creating and manipulating graphs and networks
  URL:=https://networkx.org/
  DEPENDS:=+python3-light +python3-uuid +python3-xml
endef

define Package/python3-networkx/description
NetworkX is a Python package for the creation, manipulation, and study
of the structure, dynamics, and functions of complex networks.
endef

$(eval $(call Py3Package,python3-networkx))
$(eval $(call BuildPackage,python3-networkx))
$(eval $(call BuildPackage,python3-networkx-src))
