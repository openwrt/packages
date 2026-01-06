include $(TOPDIR)/rules.mk

PKG_NAME:=sqlparse
PKG_VERSION:=0.4.4
PKG_RELEASE:=1

PYPI_NAME:=sqlparse
PKG_HASH:=d446183e84b8349fa3061f0fe7f06ca94ba65b426946ffebe6e3e8295332420c

PKG_MAINTAINER:=Peter Stadler <peter.stadler@student.uibk.ac.at>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:sqlparse_project:sqlparse

PKG_BUILD_DEPENDS:=python-flit-core/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-sqlparse
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Non-validating SQL parser
  URL:=https://github.com/andialbrecht/sqlparse
  DEPENDS:=+python3-light
endef

define Package/python3-sqlparse/description
sqlparse is a non-validating SQL parser for Python. It provides support
for parsing, splitting and formatting SQL statements.
endef

$(eval $(call Py3Package,python3-sqlparse))
$(eval $(call BuildPackage,python3-sqlparse))
$(eval $(call BuildPackage,python3-sqlparse-src))
