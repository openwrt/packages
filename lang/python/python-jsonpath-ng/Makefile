# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-jsonpath-ng
PKG_VERSION:=1.8.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com> 

PYPI_NAME:=jsonpath-ng
PYPI_SOURCE_NAME:=jsonpath_ng
PKG_HASH:=54252968134b5e549ea5b872f1df1168bd7defe1a52fed5a358c194e1943ddc3

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-jsonpath-ng
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/h2non/jsonpath-ng
  TITLE:=Standard compliant implementation of JSONPath
  DEPENDS:= \
    +python3-light \
    +python3-logging \
    +python3-ply \
    +python3-six \
    +python3-decorator
endef

define Package/python3-jsonpath-ng/description
A final implementation of JSONPath for Python that aims to be standard
compliant, including arithmetic and binary comparison operators, as
defined in the original JSONPath proposal.

This packages merges both jsonpath-rw and jsonpath-rw-ext and provides
several AST API enhancements, such as the ability to update or removes
nodes in the tree.
endef

$(eval $(call Py3Package,python3-jsonpath-ng))
$(eval $(call BuildPackage,python3-jsonpath-ng))
$(eval $(call BuildPackage,python3-jsonpath-ng-src))
