# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-schema
PKG_VERSION:=0.7.5
PKG_RELEASE:=1
PKG_MAINTAINER:=Karel Kočí <cynerd@email.cz>

PYPI_NAME:=schema
PKG_HASH:=f06717112c61895cabc4707752b88716e8420a8819d71404501e114f91043197

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE-MIT

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-schema
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/keleshev/schema
  TITLE:=Simple data validation library
  DEPENDS:=+python3-light +python3-contextlib2
endef

define Package/python3-schema/description
schema is a library for validating Python data structures, such as those
obtained from config-files, forms, external services or command-line
parsing, converted from JSON/YAML (or something else) to Python
data-types.
endef

$(eval $(call Py3Package,python3-schema))
$(eval $(call BuildPackage,python3-schema))
$(eval $(call BuildPackage,python3-schema-src))
