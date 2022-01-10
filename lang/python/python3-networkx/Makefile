#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python3-networkx
PKG_VERSION:=2.6.3
PKG_RELEASE:=$(AUTORELEASE)

PYPI_NAME:=networkx
PKG_HASH:=c0946ed31d71f1b732b5aaa6da5a0388a345019af232ce2f49c766e2d6795c51

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
  URL:=https://networkx.github.io/
  DEPENDS:=+python3-light +python3-decorator
endef

define Package/python3-networkx/description
NetworkX is a Python package for the creation, manipulation, and study
of the structure, dynamics, and functions of complex networks.
endef

$(eval $(call Py3Package,python3-networkx))
$(eval $(call BuildPackage,python3-networkx))
$(eval $(call BuildPackage,python3-networkx-src))
